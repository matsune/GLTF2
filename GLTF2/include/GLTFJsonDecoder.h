#ifndef GLTFJsonDecoder_h
#define GLTFJsonDecoder_h

#include "GLTFException.h"
#include "GLTFExtension.h"
#include "GLTFJson.h"
#include "nlohmann/json.hpp"
#include <iostream>
#include <sstream>
#include <stack>

namespace {

template <typename T> bool isValueType(const nlohmann::json &j);

template <> bool isValueType<std::string>(const nlohmann::json &j) {
  return j.is_string();
}

template <> bool isValueType<uint32_t>(const nlohmann::json &j) {
  return j.is_number_unsigned();
}

template <> bool isValueType<float>(const nlohmann::json &j) {
  return j.is_number_float() || j.is_number_integer();
}

template <> bool isValueType<bool>(const nlohmann::json &j) {
  return j.is_boolean();
}

template <typename... Args>
std::string format(const std::string &fmt, Args... args) {
  size_t len = std::snprintf(nullptr, 0, fmt.c_str(), args...);
  std::vector<char> buf(len + 1);
  std::snprintf(&buf[0], len + 1, fmt.c_str(), args...);
  return std::string(&buf[0], &buf[0] + len);
}

std::string joinStack(const std::stack<std::string> &stack,
                      const std::string &separator) {
  if (stack.empty()) {
    return "";
  }

  std::stack<std::string> tempStack = stack;

  std::vector<std::string> elements;
  while (!tempStack.empty()) {
    elements.push_back(tempStack.top());
    tempStack.pop();
  }

  std::ostringstream result;
  std::reverse(elements.begin(), elements.end());
  auto it = elements.begin();
  result << *it++;

  while (it != elements.end()) {
    result << separator << *it++;
  }

  return result.str();
}

} // namespace

namespace gltf2 {

class GLTFJsonDecoder {
public:
  static GLTFJson decode(const nlohmann::json &j) {
    return GLTFJsonDecoder().decodeJson(j);
  }

  GLTFJsonDecoder(const GLTFJsonDecoder &) = delete;
  GLTFJsonDecoder &operator=(const GLTFJsonDecoder &) = delete;

private:
  std::stack<std::string> stack;

  GLTFJsonDecoder(){};

  void pushStack(const std::string ctx) { stack.push(ctx); }

  void pushStackIndex(const std::string ctx, int index) {
    stack.push(format("%s[%d]", ctx.c_str(), index));
  }

  void popStack() { stack.pop(); }

  std::string context() const { return joinStack(stack, "."); }

  std::string contextKey(const std::string &key) const {
    return format("%s.%s", context().c_str(), key.c_str());
  }

  /**
   * @brief Decodes a JSON object as a specified type.
   *
   * This template function attempts to directly convert a given JSON object to
   * a specified type `T`. It performs a type check before conversion; if the
   * JSON object is not of the expected type, the function throws an
   * `InvalidFormatException`. This is used to enforce type safety when
   * extracting values from JSON data.
   *
   * @tparam T The type to which the JSON object should be decoded. This type
   * must be compatible with the types nlohmann::json::get<T>() supports.
   * @param j The JSON object to decode.
   * @return The decoded value of type `T`.
   *
   * @throws InvalidFormatException If the JSON object does not match the
   * expected type `T`.
   */
  template <typename T> T decodeAs(const nlohmann::json &j) {
    if (!isValueType<T>(j))
      throw InvalidFormatException(context());
    return j.get<T>();
  }

  /**
   * @brief Decodes a value from a JSON object and assigns it to the provided
   * reference.
   *
   * This template function extracts a value from a JSON object based on the
   * specified key. The extracted value is then assigned to the reference
   * variable 'to'. The function ensures that the value exists and is of the
   * expected type 'T'.
   *
   * @tparam T The expected type of the value to decode from the JSON.
   * @param j The JSON object from which to decode the value.
   * @param key The key corresponding to the value in the JSON object.
   * @param to The reference to which the decoded value will be assigned.
   *
   * @throws KeyNotFoundException If the key is not found in the JSON object or
   * the value is null.
   * @throws InvalidFormatException If the value associated with the key is not
   * of type 'T'.
   */
  template <typename T>
  void decodeValue(const nlohmann::json &j, const std::string &key, T &to) {
    if (!j.contains(key) || j[key].is_null())
      throw KeyNotFoundException(contextKey(key));
    if (!isValueType<T>(j[key]))
      throw InvalidFormatException(contextKey(key));
    j[key].get_to(to);
  }

  /**
   * @brief Decodes a JSON array from a JSON object using a specified key.
   *
   * This function checks if a JSON object contains a key pointing to a JSON
   * array. It validates the existence of the key and checks if the
   * corresponding value is actually an array. If the key is not found, or the
   * value under the key is not a JSON array, the function throws appropriate
   * exceptions. If the validation passes, it returns the JSON array.
   *
   * @param j The JSON object from which to decode the array.
   * @param key The key corresponding to the JSON array in the object.
   * @return std::vector<nlohmann::json> A vector of JSON objects extracted from
   * the JSON array.
   *
   * @throws KeyNotFoundException If the key is not found or the value under the
   * key is null.
   * @throws InvalidFormatException If the value under the key is not a JSON
   * array.
   */
  std::vector<nlohmann::json> decodeArray(const nlohmann::json &j,
                                          const std::string &key) {
    if (!j.contains(key) || j[key].is_null())
      throw KeyNotFoundException(contextKey(key));
    if (!j[key].is_array())
      throw InvalidFormatException(contextKey(key));
    return j[key].get<std::vector<nlohmann::json>>();
  }

  /**
   * @brief Decodes an optional JSON array from a specified key.
   *
   * Attempts to retrieve a JSON array from the provided JSON object using the
   * specified key. Returns an optional containing the array if it exists and is
   * valid, or std::nullopt if the key does not exist or the value at the key is
   * null. Throws an exception if the key exists but the value is not a JSON
   * array.
   *
   * @param j The JSON object from which to decode the array.
   * @param key The key corresponding to the target JSON array in the object.
   * @return std::optional<std::vector<nlohmann::json>> containing the JSON
   * array if valid, otherwise std::nullopt.
   *
   * @throws InvalidFormatException If the key exists but the value is not a
   * JSON array.
   */
  std::optional<std::vector<nlohmann::json>>
  decodeOptionalArray(const nlohmann::json &j, const std::string &key) {
    if (!j.contains(key) || j[key].is_null())
      return std::nullopt;
    if (!j[key].is_array())
      throw InvalidFormatException(contextKey(key));
    return j[key].get<std::vector<nlohmann::json>>();
  }

  /**
   * @brief Decodes a JSON object from a specified key.
   *
   * Retrieves a JSON object from the given JSON object using the specified key.
   * Throws an exception if the key does not exist, the value is null, or the
   * value is not a JSON object.
   *
   * @param j The JSON object from which to decode the object.
   * @param key The key corresponding to the target JSON object in the object.
   * @return nlohmann::json The decoded JSON object.
   *
   * @throws KeyNotFoundException If the key does not exist or the value at the
   * key is null.
   * @throws InvalidFormatException If the value at the key is not a JSON
   * object.
   */
  nlohmann::json decodeObj(const nlohmann::json &j, const std::string &key) {
    if (!j.contains(key) || j[key].is_null())
      throw KeyNotFoundException(contextKey(key));
    if (!j[key].is_object())
      throw InvalidFormatException(contextKey(key));
    return j[key].get<nlohmann::json>();
  }

  /**
   * @brief Decodes an optional JSON object from a specified key.
   *
   * Attempts to retrieve a JSON object from the provided JSON object using the
   * specified key. Returns an optional containing the JSON object if it exists
   * and is a valid object, or std::nullopt if the key does not exist or the
   * value at the key is null. Throws an exception if the key exists but the
   * value is not a JSON object.
   *
   * @param j The JSON object from which to decode the object.
   * @param key The key corresponding to the target JSON object in the object.
   * @return std::optional<nlohmann::json> containing the JSON object if valid,
   * otherwise std::nullopt.
   *
   * @throws InvalidFormatException If the key exists but the value is not a
   * JSON object.
   */
  std::optional<nlohmann::json> decodeOptionalObj(const nlohmann::json &j,
                                                  const std::string &key) {
    if (!j.contains(key) || j[key].is_null())
      return std::nullopt;
    if (!j[key].is_object())
      throw InvalidFormatException(contextKey(key));
    return j[key].get<nlohmann::json>();
  }

  /**
   * @brief Optionally decodes a value from a JSON object and assigns it to the
   * provided optional reference.
   *
   * This template function attempts to extract a value from a JSON object based
   * on the specified key. If the key is found and the value is not null, and if
   * the value matches the expected type 'T', the function sets the optional
   * 'to' to the decoded value. If the key does not exist or the value is null,
   * the function leaves the optional 'to' in an unset state (std::nullopt).
   * This allows for optional configuration parameters in JSON data structures.
   *
   * @tparam T The type of the value expected to decode from the JSON. The
   * actual value is expected to be convertible to type 'T'.
   * @param j The JSON object from which to decode the value.
   * @param key The key corresponding to the value in the JSON object.
   * @param to The optional reference to which the decoded value will be
   * assigned if valid.
   *
   * @throws InvalidFormatException If the value exists but does not match the
   * expected type 'T'.
   */
  template <typename T>
  void decodeValue(const nlohmann::json &j, const std::string &key,
                   std::optional<T> &to) {
    if (!j.contains(key) || j[key].is_null())
      return;
    if (!isValueType<T>(j[key]))
      throw InvalidFormatException(contextKey(key));
    T value;
    j[key].get_to(value);
    to = value;
  }

  /**
   * @brief Decodes a JSON array from a specified key, transforms each element,
   * and stores the results.
   *
   * This template function extracts a JSON array from the given JSON object
   * using the specified key. It applies a mapping function to each element of
   * the array to convert each JSON entry into a type `T` and stores the
   * transformed elements in a provided vector. This function leverages
   * `decodeArray` to retrieve the JSON array and validates each transformation
   * using the provided mapping function.
   *
   * @tparam T The target type of elements after transformation.
   * @param j The JSON object from which the array is decoded.
   * @param key The key corresponding to the target JSON array in the object.
   * @param to Reference to a vector where the transformed elements are stored.
   * @param mapFunc A function that takes a JSON object and returns an object of
   * type `T`. This function is applied to each element of the decoded array.
   */
  template <typename T>
  void
  decodeArrayWithMapElem(const nlohmann::json &j, const std::string &key,
                         std::vector<T> &to,
                         std::function<T(const nlohmann::json &)> mapFunc) {
    auto array = decodeArray(j, key);

    std::vector<T> values;
    for (const auto &value : array) {
      pushStackIndex(key, static_cast<int>(values.size()));
      values.push_back(mapFunc(value));
      popStack();
    }
    to = values;
  }

  /**
   * @brief Optionally decodes a JSON array from a specified key and applies a
   * transformation function to each element.
   *
   * This template function attempts to extract a JSON array from the given JSON
   * object 'j' using the specified key. If the array exists, it applies a
   * mapping function to each element of the JSON array to convert each JSON
   * entry into a type `T` and stores the transformed elements in an optional
   * vector. If the array does not exist, the function sets the optional 'to' to
   * std::nullopt. This function is useful for handling JSON data where the
   * presence of an array is not guaranteed.
   *
   * @tparam T The target type of elements after transformation.
   * @param j The JSON object from which to decode the array.
   * @param key The key corresponding to the target JSON array in the object.
   * @param to Reference to an optional vector where the transformed elements
   * are to be stored if the array exists.
   * @param mapFunc A function that takes a JSON object and returns an object of
   * type `T`. This function is applied to each element of the decoded array if
   * the array exists.
   */
  template <typename T>
  void
  decodeArrayWithMapElem(const nlohmann::json &j, const std::string &key,
                         std::optional<std::vector<T>> &to,
                         std::function<T(const nlohmann::json &)> mapFunc) {
    auto array = decodeOptionalArray(j, key);
    if (!array)
      return;

    std::vector<T> values;
    for (const auto &value : *array) {
      pushStackIndex(key, static_cast<int>(values.size()));
      values.push_back(mapFunc(value));
      popStack();
    }
    to = values;
  }

  /**
   * @brief Decodes an array of JSON objects into a vector of type T.
   *
   * This function extracts an array of JSON objects from the provided JSON
   * object 'j' using the specified key. It then maps each element of the JSON
   * array to type T using the 'decodeAs<T>' function and stores the results in
   * the vector 'to'. The function ensures that each element in the JSON array
   * matches the expected type T, throwing an exception if a type mismatch is
   * detected.
   *
   * @tparam T The type into which each JSON element should be converted. This
   * type must be compatible with the nlohmann::json::get<T>() operation, as it
   *           will be used to convert each JSON object in the array.
   * @param j The JSON object from which to decode the array.
   * @param key The key corresponding to the target JSON array in the object.
   * @param to Reference to a vector where the decoded and converted elements
   * are stored.
   */
  template <typename T>
  void decodeValue(const nlohmann::json &j, const std::string &key,
                   std::vector<T> &to) {
    decodeArrayWithMapElem<T>(j, key, to,
                              [this](const nlohmann::json &value) -> T {
                                return decodeAs<T>(value);
                              });
  }

  /**
   * @brief Decodes an array of JSON values into an optional vector of type T.
   *
   * This function attempts to decode a JSON array specified by a key into a
   * vector of type T, applying a provided mapping function to each element. If
   * the key does not exist or the value is null, the resulting vector will be
   * empty (std::nullopt).
   *
   * @tparam T The type to which the JSON elements should be converted.
   * @param j The JSON object from which to decode the array.
   * @param key The key corresponding to the JSON array.
   * @param to Reference to an optional vector where the decoded and converted
   * elements will be stored.
   */
  template <typename T>
  void decodeValue(const nlohmann::json &j, const std::string &key,
                   std::optional<std::vector<T>> &to) {
    decodeArrayWithMapElem<T>(j, key, to,
                              [this](const nlohmann::json &value) -> T {
                                return decodeAs<T>(value);
                              });
  }

  /**
   * @brief Decodes a JSON value into a type T using a custom mapping function.
   *
   * This function extracts a value from a JSON object using the specified key
   * and applies a mapping function to convert this value to type T. If the key
   * does not exist or the value is null, it throws an exception.
   *
   * @tparam T The type to which the JSON value should be converted.
   * @param j The JSON object from which to decode the value.
   * @param key The key corresponding to the value.
   * @param to Reference to the variable where the decoded value will be stored.
   * @param mapFunc A function that takes a JSON value and returns a value of
   * type T.
   *
   * @throws KeyNotFoundException If the key does not exist or the value is
   * null.
   */
  template <typename T>
  void decodeValueWithMap(const nlohmann::json &j, const std::string &key,
                          T &to,
                          std::function<T(const nlohmann::json &)> mapFunc) {
    if (!j.contains(key) || j[key].is_null())
      throw KeyNotFoundException(contextKey(key));
    to = mapFunc(j[key]);
  }

  /**
   * @brief Optionally decodes a JSON value into a type T using a custom mapping
   * function.
   *
   * Similar to the non-optional version, but sets the result into an optional.
   * If the key does not exist or the value is null, the optional is set to
   * std::nullopt.
   *
   * @tparam T The type to which the JSON value should be converted, if
   * available.
   * @param j The JSON object from which to decode the value.
   * @param key The key corresponding to the value.
   * @param to Optional reference where the decoded value will be stored if
   * available.
   * @param mapFunc A function that converts a JSON value into type T.
   */
  template <typename T>
  void decodeValueWithMap(const nlohmann::json &j, const std::string &key,
                          std::optional<T> &to,
                          std::function<T(const nlohmann::json &)> mapFunc) {
    if (!j.contains(key) || j[key].is_null())
      return;
    to = mapFunc(j[key]);
  }

  /**
   * @brief Decodes a JSON object into a type T using a custom mapping function.
   *
   * Extracts a JSON object using a specified key and applies a mapping function
   * to convert this object to type T. If the object is not present or is not a
   * valid JSON object, throws an exception.
   *
   * @tparam T The type to which the JSON object should be converted.
   * @param j The JSON object from which to decode.
   * @param key The key corresponding to the object.
   * @param to Reference to the variable where the decoded object will be
   * stored.
   * @param mapFunc A function that takes a JSON object and returns a value of
   * type T.
   */
  template <typename T>
  void decodeObjWithMap(const nlohmann::json &j, const std::string &key, T &to,
                        std::function<T(const nlohmann::json &)> mapFunc) {
    auto obj = decodeObj(j, key);
    pushStack(key);
    to = mapFunc(obj);
    popStack();
  }

  /**
   * @brief Optionally decodes a JSON object into a type T using a custom
   * mapping function.
   *
   * Attempts to extract a JSON object using the specified key and applies a
   * mapping function if the object exists. If the key does not exist or the
   * value is null, the result is set to std::nullopt.
   *
   * @tparam T The type to which the JSON object should be converted, if
   * available.
   * @param j The JSON object from which to decode.
   * @param key The key corresponding to the object.
   * @param to Optional reference where the decoded object will be stored if
   * available.
   * @param mapFunc A function that converts a JSON object into type T.
   */
  template <typename T>
  void decodeObjWithMap(const nlohmann::json &j, const std::string &key,
                        std::optional<T> &to,
                        std::function<T(const nlohmann::json &)> mapFunc) {
    auto obj = decodeOptionalObj(j, key);
    if (!obj)
      return;

    pushStack(key);
    to = mapFunc(*obj);
    popStack();
  }

  /**
   * @brief Decodes a JSON value into an enumerated type using a custom mapping
   * function.
   *
   * This function extracts a value from a JSON object using the specified key,
   * interprets it as a uint32_t, and then uses the provided mapping function to
   * attempt to convert this uint32_t to an enumerated type T. If the mapping is
   * successful, the result is stored in the reference 'to'. If the mapping
   * fails, indicating an invalid or unsupported enumeration value, the function
   * throws an InvalidFormatException.
   *
   * @tparam T The enumerated type to which the JSON value should be converted.
   * @param j The JSON object from which to decode the value.
   * @param key The key corresponding to the value in the JSON object.
   * @param to Reference to the variable where the decoded enumeration value
   * will be stored.
   * @param mapFunc A function that takes a uint32_t and returns an optional<T>.
   * This function defines the mapping from uint32_t to the enumerated type T.
   * @throws InvalidFormatException If the mapping function fails to convert the
   * uint32_t to a valid T.
   */
  template <typename T>
  void decodeEnumValue(const nlohmann::json &j, const std::string &key, T &to,
                       std::function<std::optional<T>(uint32_t)> mapFunc) {
    decodeValueWithMap<T>(j, key, to,
                          [this, mapFunc](const nlohmann::json &value) {
                            auto enumValue = mapFunc(decodeAs<uint32_t>(value));
                            if (!enumValue)
                              throw InvalidFormatException(context());
                            return *enumValue;
                          });
  }

  /**
   * @brief Optionally decodes a JSON value into an enumerated type using a
   * custom mapping function.
   *
   * Similar to the non-optional version, this function extracts a value from a
   * JSON object using a specified key, interprets it as a uint32_t, and
   * attempts to map this value to an enumerated type T using a provided mapping
   * function. The result, if successfully mapped, is stored in the optional
   * 'to'. If the mapping fails, indicating an invalid or unsupported
   * enumeration value, the function throws an InvalidFormatException.
   *
   * @tparam T The enumerated type to which the JSON value should be optionally
   * converted.
   * @param j The JSON object from which to decode the value.
   * @param key The key corresponding to the value in the JSON object.
   * @param to Optional reference where the decoded enumeration value will be
   * stored if valid.
   * @param mapFunc A function that takes a uint32_t and returns an optional<T>.
   * This function defines the mapping from uint32_t to the enumerated type T.
   * @throws InvalidFormatException If the mapping function fails to convert the
   * uint32_t to a valid T.
   */
  template <typename T>
  void decodeEnumValue(const nlohmann::json &j, const std::string &key,
                       std::optional<T> &to,
                       std::function<std::optional<T>(uint32_t)> mapFunc) {
    decodeValueWithMap<T>(j, key, to,
                          [this, mapFunc](const nlohmann::json &value) {
                            auto enumValue = mapFunc(decodeAs<uint32_t>(value));
                            if (!enumValue)
                              throw InvalidFormatException(context());
                            return *enumValue;
                          });
  }

  template <typename T>
  void decodeEnumValue(
      const nlohmann::json &j, const std::string &key, T &to,
      std::function<std::optional<T>(const std::string &)> mapFunc) {
    decodeValueWithMap<T>(
        j, key, to, [this, mapFunc](const nlohmann::json &value) {
          auto enumValue = mapFunc(decodeAs<std::string>(value));
          if (!enumValue)
            throw InvalidFormatException(context());
          return *enumValue;
        });
  }

  template <typename T>
  void decodeEnumValue(
      const nlohmann::json &j, const std::string &key, std::optional<T> &to,
      std::function<std::optional<T>(const std::string &)> mapFunc) {
    decodeValueWithMap<T>(
        j, key, to, [this, mapFunc](const nlohmann::json &value) {
          auto enumValue = mapFunc(decodeAs<std::string>(value));
          if (!enumValue)
            throw InvalidFormatException(context());
          return *enumValue;
        });
  }

  GLTFAccessorSparseIndices
  decodeAccessorSparseIndices(const nlohmann::json &j) {
    GLTFAccessorSparseIndices indices;
    decodeValue(j, "bufferView", indices.bufferView);
    decodeValue(j, "byteOffset", indices.byteOffset);

    decodeEnumValue<GLTFAccessorSparseIndices::ComponentType>(
        j, "componentType", indices.componentType,
        GLTFAccessorSparseIndices::ComponentTypeFromInt);
    return indices;
  }

  GLTFAccessorSparseValues decodeAccessorSparseValues(const nlohmann::json &j) {
    GLTFAccessorSparseValues values;
    decodeValue(j, "bufferView", values.bufferView);
    decodeValue(j, "byteOffset", values.byteOffset);
    return values;
  }

  GLTFAccessorSparse decodeAccessorSparse(const nlohmann::json &j) {
    GLTFAccessorSparse sparse;
    decodeValue(j, "count", sparse.count);
    decodeObjWithMap<GLTFAccessorSparseIndices>(
        j, "indices", sparse.indices, [this](const nlohmann::json &value) {
          return decodeAccessorSparseIndices(value);
        });
    decodeObjWithMap<GLTFAccessorSparseValues>(
        j, "values", sparse.values, [this](const nlohmann::json &value) {
          return decodeAccessorSparseValues(value);
        });
    return sparse;
  }

  GLTFAccessor decodeAccessor(const nlohmann::json &j) {
    GLTFAccessor accessor;
    decodeValue(j, "bufferView", accessor.bufferView);
    decodeValue(j, "byteOffset", accessor.byteOffset);
    decodeEnumValue<GLTFAccessor::ComponentType>(
        j, "componentType", accessor.componentType,
        GLTFAccessor::ComponentTypeFromInt);
    decodeValue(j, "normalized", accessor.normalized);
    decodeValue(j, "count", accessor.count);
    decodeEnumValue<GLTFAccessor::Type>(j, "type", accessor.type,
                                        GLTFAccessor::TypeFromString);
    decodeValue(j, "max", accessor.max);
    decodeValue(j, "min", accessor.min);
    decodeObjWithMap<GLTFAccessorSparse>(j, "sparse", accessor.sparse,
                                         [this](const nlohmann::json &value) {
                                           return decodeAccessorSparse(value);
                                         });
    decodeValue(j, "name", accessor.name);
    return accessor;
  }

  GLTFAnimationChannelTarget
  decodeAnimationChannelTarget(const nlohmann::json &j) {
    GLTFAnimationChannelTarget target;
    decodeValue(j, "node", target.node);
    decodeEnumValue<GLTFAnimationChannelTarget::Path>(
        j, "path", target.path, GLTFAnimationChannelTarget::PathFromString);
    return target;
  }

  GLTFAnimationChannel decodeAnimationChannel(const nlohmann::json &j) {
    GLTFAnimationChannel channel;
    decodeValue(j, "sampler", channel.sampler);
    decodeObjWithMap<GLTFAnimationChannelTarget>(
        j, "target", channel.target, [this](const nlohmann::json &value) {
          return decodeAnimationChannelTarget(value);
        });
    return channel;
  }

  GLTFAnimationSampler decodeAnimationSampler(const nlohmann::json &j) {
    GLTFAnimationSampler sampler;
    decodeValue(j, "input", sampler.input);
    decodeEnumValue<GLTFAnimationSampler::Interpolation>(
        j, "interpolation", sampler.interpolation,
        GLTFAnimationSampler::InterpolationFromString);
    decodeValue(j, "output", sampler.output);
    return sampler;
  }

  GLTFAnimation decodeAnimation(const nlohmann::json &j) {
    GLTFAnimation animation;
    decodeValue(j, "name", animation.name);

    decodeArrayWithMapElem<GLTFAnimationChannel>(
        j, "channels", animation.channels, [this](const nlohmann::json &value) {
          return decodeAnimationChannel(value);
        });

    decodeArrayWithMapElem<GLTFAnimationSampler>(
        j, "samplers", animation.samplers, [this](const nlohmann::json &value) {
          return decodeAnimationSampler(value);
        });

    return animation;
  }

  GLTFAsset decodeAsset(const nlohmann::json &j) {
    GLTFAsset asset;
    decodeValue(j, "copyright", asset.copyright);
    decodeValue(j, "generator", asset.generator);
    decodeValue(j, "version", asset.version);
    decodeValue(j, "minVersion", asset.minVersion);
    return asset;
  }

  GLTFBuffer decodeBuffer(const nlohmann::json &j) {
    GLTFBuffer buffer;
    decodeValue(j, "uri", buffer.uri);
    decodeValue(j, "byteLength", buffer.byteLength);
    decodeValue(j, "name", buffer.name);
    return buffer;
  }

  GLTFBufferView decodeBufferView(const nlohmann::json &j) {
    GLTFBufferView bufferView;
    decodeValue(j, "buffer", bufferView.buffer);
    decodeValue(j, "byteOffset", bufferView.byteOffset);
    decodeValue(j, "byteLength", bufferView.byteLength);
    decodeValue(j, "byteStride", bufferView.byteStride);
    decodeValue(j, "target", bufferView.target);
    decodeValue(j, "name", bufferView.name);
    return bufferView;
  }

  GLTFCameraOrthographic decodeCameraOrthographic(const nlohmann::json &j) {
    GLTFCameraOrthographic camera;
    decodeValue(j, "xmag", camera.xmag);
    decodeValue(j, "ymag", camera.ymag);
    decodeValue(j, "zfar", camera.zfar);
    decodeValue(j, "znear", camera.znear);
    return camera;
  }

  GLTFCameraPerspective decodeCameraPerspective(const nlohmann::json &j) {
    GLTFCameraPerspective camera;
    decodeValue(j, "aspectRatio", camera.aspectRatio);
    decodeValue(j, "yfov", camera.yfov);
    decodeValue(j, "zfar", camera.zfar);
    decodeValue(j, "znear", camera.znear);
    return camera;
  }

  GLTFCamera decodeCamera(const nlohmann::json &j) {
    GLTFCamera camera;
    decodeEnumValue<GLTFCamera::Type>(j, "type", camera.type,
                                      GLTFCamera::TypeFromString);
    decodeValue(j, "name", camera.name);

    if (camera.type == GLTFCamera::Type::PERSPECTIVE) {
      decodeObjWithMap<GLTFCameraPerspective>(
          j, "perspective", camera.perspective,
          [this](const nlohmann::json &value) {
            return decodeCameraPerspective(value);
          });
    } else if (camera.type == GLTFCamera::Type::ORTHOGRAPHIC) {
      decodeObjWithMap<GLTFCameraOrthographic>(
          j, "orthographic", camera.orthographic,
          [this](const nlohmann::json &value) {
            return decodeCameraOrthographic(value);
          });
    }

    return camera;
  }

  GLTFImage decodeImage(const nlohmann::json &j) {
    GLTFImage image;
    decodeValue(j, "uri", image.uri);
    decodeEnumValue<GLTFImage::MimeType>(j, "mimeType", image.mimeType,
                                         GLTFImage::MimeTypeFromString);
    decodeValue(j, "bufferView", image.bufferView);
    decodeValue(j, "name", image.name);

    return image;
  }

  GLTFTexture decodeTexture(const nlohmann::json &j) {
    GLTFTexture texture;
    decodeValue(j, "sampler", texture.sampler);
    decodeValue(j, "source", texture.source);
    decodeValue(j, "name", texture.name);
    return texture;
  }

  GLTFTextureInfo decodeTextureInfo(const nlohmann::json &j) {
    GLTFTextureInfo textureInfo;
    decodeValue(j, "index", textureInfo.index);
    decodeValue(j, "texCoord", textureInfo.texCoord);
    auto extensionsObj = decodeOptionalObj(j, "extensions");
    if (extensionsObj) {
      decodeObjWithMap<KHRTextureTransform>(
          *extensionsObj, GLTFExtensionKHRTextureTransform,
          textureInfo.khrTextureTransform, [this](const nlohmann::json &value) {
            return decodeKHRTextureTransform(value);
          });
    }
    return textureInfo;
  }

  GLTFMaterialPBRMetallicRoughness
  decodeMaterialPBRMetallicRoughness(const nlohmann::json &j) {
    GLTFMaterialPBRMetallicRoughness pbr;
    decodeValueWithMap<std::array<float, 4>>(
        j, "baseColorFactor", pbr.baseColorFactor,
        [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 4>>();
        });
    decodeObjWithMap<GLTFTextureInfo>(j, "baseColorTexture",
                                      pbr.baseColorTexture,
                                      [this](const nlohmann::json &value) {
                                        return decodeTextureInfo(value);
                                      });
    decodeValue(j, "metallicFactor", pbr.metallicFactor);
    decodeValue(j, "roughnessFactor", pbr.roughnessFactor);
    decodeObjWithMap<GLTFTextureInfo>(j, "metallicRoughnessTexture",
                                      pbr.metallicRoughnessTexture,
                                      [this](const nlohmann::json &value) {
                                        return decodeTextureInfo(value);
                                      });
    return pbr;
  }

  GLTFMaterialNormalTextureInfo
  decodeMaterialNormalTextureInfo(const nlohmann::json &j) {
    GLTFMaterialNormalTextureInfo normal;
    decodeValue(j, "index", normal.index);
    decodeValue(j, "texCoord", normal.texCoord);
    decodeValue(j, "scale", normal.scale);
    auto extensionsObj = decodeOptionalObj(j, "extensions");
    if (extensionsObj) {
      decodeObjWithMap<KHRTextureTransform>(
          *extensionsObj, GLTFExtensionKHRTextureTransform,
          normal.khrTextureTransform, [this](const nlohmann::json &value) {
            return decodeKHRTextureTransform(value);
          });
    }
    return normal;
  }

  GLTFMaterialOcclusionTextureInfo
  decodeMaterialOcclusionTextureInfo(const nlohmann::json &j) {
    GLTFMaterialOcclusionTextureInfo occlusion;
    decodeValue(j, "index", occlusion.index);
    decodeValue(j, "texCoord", occlusion.texCoord);
    decodeValue(j, "strength", occlusion.strength);
    auto extensionsObj = decodeOptionalObj(j, "extensions");
    if (extensionsObj) {
      decodeObjWithMap<KHRTextureTransform>(
          *extensionsObj, GLTFExtensionKHRTextureTransform,
          occlusion.khrTextureTransform, [this](const nlohmann::json &value) {
            return decodeKHRTextureTransform(value);
          });
    }
    return occlusion;
  }

  GLTFMaterial decodeMaterial(const nlohmann::json &j) {
    GLTFMaterial material;
    decodeValue(j, "name", material.name);
    decodeObjWithMap<GLTFMaterialPBRMetallicRoughness>(
        j, "pbrMetallicRoughness", material.pbrMetallicRoughness,
        [this](const nlohmann::json &value) {
          return decodeMaterialPBRMetallicRoughness(value);
        });
    decodeObjWithMap<GLTFMaterialNormalTextureInfo>(
        j, "normalTexture", material.normalTexture,
        [this](const nlohmann::json &value) {
          return decodeMaterialNormalTextureInfo(value);
        });
    decodeObjWithMap<GLTFMaterialOcclusionTextureInfo>(
        j, "occlusionTexture", material.occlusionTexture,
        [this](const nlohmann::json &value) {
          return decodeMaterialOcclusionTextureInfo(value);
        });
    decodeObjWithMap<GLTFTextureInfo>(j, "emissiveTexture",
                                      material.emissiveTexture,
                                      [this](const nlohmann::json &value) {
                                        return decodeTextureInfo(value);
                                      });
    decodeValueWithMap<std::array<float, 3>>(
        j, "emissiveFactor", material.emissiveFactor,
        [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 3>>();
        });
    decodeEnumValue<GLTFMaterial::AlphaMode>(j, "alphaMode", material.alphaMode,
                                             GLTFMaterial::AlphaModeFromString);
    decodeValue(j, "alphaCutoff", material.alphaCutoff);
    decodeValue(j, "doubleSided", material.doubleSided);

    auto extensionsObj = decodeOptionalObj(j, "extensions");
    if (extensionsObj) {
      bool isUnlit = extensionsObj->contains(GLTFExtensionKHRMaterialsUnlit);
      material.unlit = isUnlit;

      decodeObjWithMap<KHRMaterialAnisotropy>(
          *extensionsObj, GLTFExtensionKHRMaterialsAnisotropy,
          material.anisotropy, [this](const nlohmann::json &value) {
            return decodeKHRMaterialAnisotropy(value);
          });

      decodeObjWithMap<KHRMaterialClearcoat>(
          *extensionsObj, GLTFExtensionKHRMaterialsClearcoat,
          material.clearcoat, [this](const nlohmann::json &value) {
            return decodeKHRMaterialClearcoat(value);
          });

      decodeObjWithMap<KHRMaterialDispersion>(
          *extensionsObj, GLTFExtensionKHRMaterialsDispersion,
          material.dispersion, [this](const nlohmann::json &value) {
            return decodeKHRMaterialDispersion(value);
          });

      decodeObjWithMap<KHRMaterialEmissiveStrength>(
          *extensionsObj, GLTFExtensionKHRMaterialsEmissiveStrength,
          material.emissiveStrength, [this](const nlohmann::json &value) {
            return decodeKHRMaterialEmissiveStrength(value);
          });

      decodeObjWithMap<KHRMaterialIor>(
          *extensionsObj, GLTFExtensionKHRMaterialsIor, material.ior,
          [this](const nlohmann::json &value) {
            return decodeKHRMaterialIor(value);
          });

      decodeObjWithMap<KHRMaterialIridescence>(
          *extensionsObj, GLTFExtensionKHRMaterialsIridescence,
          material.iridescence, [this](const nlohmann::json &value) {
            return decodeKHRMaterialIridescence(value);
          });

      decodeObjWithMap<KHRMaterialSheen>(
          *extensionsObj, GLTFExtensionKHRMaterialsSheen, material.sheen,
          [this](const nlohmann::json &value) {
            return decodeKHRMaterialSheen(value);
          });

      decodeObjWithMap<KHRMaterialSpecular>(
          *extensionsObj, GLTFExtensionKHRMaterialsSpecular, material.specular,
          [this](const nlohmann::json &value) {
            return decodeKHRMaterialSpecular(value);
          });

      decodeObjWithMap<KHRMaterialTransmission>(
          *extensionsObj, GLTFExtensionKHRMaterialsTransmission,
          material.transmission, [this](const nlohmann::json &value) {
            return decodeKHRMaterialTransmission(value);
          });

      decodeObjWithMap<KHRMaterialVolume>(
          *extensionsObj, GLTFExtensionKHRMaterialsVolume, material.volume,
          [this](const nlohmann::json &value) {
            return decodeKHRMaterialVolume(value);
          });
    }

    return material;
  }

  void decodeMeshPrimitiveTarget(const nlohmann::json &j,
                                 GLTFMeshPrimitiveTarget &target) {
    decodeValue(j, "POSITION", target.position);
    decodeValue(j, "NORMAL", target.normal);
    decodeValue(j, "TANGENT", target.tangent);
  }

  std::optional<std::vector<uint32_t>>
  decodeMeshPrimitiveAttributesSequenceKey(const nlohmann::json &j,
                                           const std::string &prefix) {
    std::vector<uint32_t> values;
    int i = 0;
    while (true) {
      std::string key = format("%s_%d", prefix.c_str(), i);
      if (!j.contains(key) || j[key].is_null())
        break;
      if (!j[key].is_number_unsigned())
        throw InvalidFormatException(context());
      values.push_back(j[key].get<uint32_t>());
      i++;
    }
    return values.empty() ? std::nullopt : std::make_optional(values);
  }

  GLTFMeshPrimitiveAttributes
  decodeMeshPrimitiveAttributes(const nlohmann::json &j) {
    GLTFMeshPrimitiveAttributes attributes;
    decodeMeshPrimitiveTarget(j, attributes);
    attributes.texcoords =
        decodeMeshPrimitiveAttributesSequenceKey(j, "TEXCOORD");
    attributes.colors = decodeMeshPrimitiveAttributesSequenceKey(j, "COLOR");
    attributes.joints = decodeMeshPrimitiveAttributesSequenceKey(j, "JOINTS");
    attributes.weights = decodeMeshPrimitiveAttributesSequenceKey(j, "WEIGHTS");
    return attributes;
  }

  GLTFMeshPrimitive decodeMeshPrimitive(const nlohmann::json &j) {
    GLTFMeshPrimitive primitive;
    decodeObjWithMap<GLTFMeshPrimitiveAttributes>(
        j, "attributes", primitive.attributes,
        [this](const nlohmann::json &value) {
          return decodeMeshPrimitiveAttributes(value);
        });
    decodeValue(j, "indices", primitive.indices);
    decodeValue(j, "material", primitive.material);
    decodeEnumValue<GLTFMeshPrimitive::Mode>(j, "mode", primitive.mode,
                                             GLTFMeshPrimitive::ModeFromInt);

    decodeArrayWithMapElem<GLTFMeshPrimitiveTarget>(
        j, "targets", primitive.targets, [this](const nlohmann::json &value) {
          GLTFMeshPrimitiveTarget target;
          decodeMeshPrimitiveTarget(value, target);
          return target;
        });

    auto extensionsObj = decodeOptionalObj(j, "extensions");
    if (extensionsObj) {
      decodeObjWithMap<GLTFMeshPrimitiveDracoExtension>(
          *extensionsObj, GLTFExtensionKHRDracoMeshCompression,
          primitive.dracoExtension, [this](const nlohmann::json &value) {
            return decodeMeshPrimitiveDracoExtension(value);
          });
    }

    return primitive;
  }

  GLTFMesh decodeMesh(const nlohmann::json &j) {
    GLTFMesh mesh;
    decodeArrayWithMapElem<GLTFMeshPrimitive>(
        j, "primitives", mesh.primitives, [this](const nlohmann::json &value) {
          return decodeMeshPrimitive(value);
        });
    decodeValue(j, "name", mesh.name);
    decodeValue(j, "weights", mesh.weights);
    return mesh;
  }

  GLTFNode decodeNode(const nlohmann::json &j) {
    GLTFNode node;

    decodeValue(j, "camera", node.camera);
    decodeValue(j, "children", node.children);
    decodeValue(j, "skin", node.skin);
    decodeValueWithMap<std::array<float, 16>>(
        j, "matrix", node.matrix, [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 16>>();
        });
    decodeValue(j, "mesh", node.mesh);
    decodeValueWithMap<std::array<float, 4>>(
        j, "rotation", node.rotation, [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 4>>();
        });
    decodeValueWithMap<std::array<float, 3>>(
        j, "scale", node.scale, [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 3>>();
        });
    decodeValueWithMap<std::array<float, 3>>(
        j, "translation", node.translation,
        [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 3>>();
        });
    decodeValue(j, "weights", node.weights);
    decodeValue(j, "name", node.name);

    return node;
  }

  GLTFSampler decodeSampler(const nlohmann::json &j) {
    GLTFSampler sampler;

    decodeEnumValue<GLTFSampler::MagFilter>(j, "magFilter", sampler.magFilter,
                                            GLTFSampler::MagFilterFromInt);

    decodeEnumValue<GLTFSampler::MinFilter>(j, "minFilter", sampler.minFilter,
                                            GLTFSampler::MinFilterFromInt);

    decodeEnumValue<GLTFSampler::WrapMode>(j, "wrapS", sampler.wrapS,
                                           GLTFSampler::WrapModeFromInt);

    decodeEnumValue<GLTFSampler::WrapMode>(j, "wrapT", sampler.wrapT,
                                           GLTFSampler::WrapModeFromInt);

    decodeValue(j, "name", sampler.name);

    return sampler;
  }

  GLTFScene decodeScene(const nlohmann::json &j) {
    GLTFScene scene;
    decodeValue(j, "nodes", scene.nodes);
    decodeValue(j, "name", scene.name);
    return scene;
  }

  GLTFSkin decodeSkin(const nlohmann::json &j) {
    GLTFSkin skin;
    decodeValue(j, "inverseBindMatrices", skin.inverseBindMatrices);
    decodeValue(j, "skeleton", skin.skeleton);
    decodeValue(j, "joints", skin.joints);
    decodeValue(j, "name", skin.name);
    return skin;
  }

  GLTFJson decodeJson(const nlohmann::json &j) {
    pushStack("root");

    GLTFJson data;

    decodeValue(j, "extensionsUsed", data.extensionsUsed);
    decodeValue(j, "extensionsRequired", data.extensionsRequired);

    decodeArrayWithMapElem<GLTFAccessor>(
        j, "accessors", data.accessors,
        [this](const nlohmann::json &item) { return decodeAccessor(item); });
    decodeArrayWithMapElem<GLTFAnimation>(
        j, "animations", data.animations,
        [this](const nlohmann::json &item) { return decodeAnimation(item); });

    decodeObjWithMap<GLTFAsset>(
        j, "asset", data.asset,
        [this](const nlohmann::json &obj) { return decodeAsset(obj); });

    decodeArrayWithMapElem<GLTFBuffer>(
        j, "buffers", data.buffers,
        [this](const nlohmann::json &item) { return decodeBuffer(item); });
    decodeArrayWithMapElem<GLTFBufferView>(
        j, "bufferViews", data.bufferViews,
        [this](const nlohmann::json &item) { return decodeBufferView(item); });
    decodeArrayWithMapElem<GLTFCamera>(
        j, "cameras", data.cameras,
        [this](const nlohmann::json &item) { return decodeCamera(item); });
    decodeArrayWithMapElem<GLTFImage>(
        j, "images", data.images,
        [this](const nlohmann::json &item) { return decodeImage(item); });
    decodeArrayWithMapElem<GLTFMaterial>(
        j, "materials", data.materials,
        [this](const nlohmann::json &item) { return decodeMaterial(item); });
    decodeArrayWithMapElem<GLTFMesh>(
        j, "meshes", data.meshes,
        [this](const nlohmann::json &item) { return decodeMesh(item); });
    decodeArrayWithMapElem<GLTFNode>(
        j, "nodes", data.nodes,
        [this](const nlohmann::json &item) { return decodeNode(item); });
    decodeArrayWithMapElem<GLTFSampler>(
        j, "samplers", data.samplers,
        [this](const nlohmann::json &item) { return decodeSampler(item); });

    decodeValue(j, "scene", data.scene);

    decodeArrayWithMapElem<GLTFScene>(
        j, "scenes", data.scenes,
        [this](const nlohmann::json &item) { return decodeScene(item); });
    decodeArrayWithMapElem<GLTFSkin>(
        j, "skins", data.skins,
        [this](const nlohmann::json &item) { return decodeSkin(item); });
    decodeArrayWithMapElem<GLTFTexture>(
        j, "textures", data.textures,
        [this](const nlohmann::json &item) { return decodeTexture(item); });

    auto extensionsObj = decodeOptionalObj(j, "extensions");
    if (extensionsObj) {
      auto lightsPunctualObj =
          decodeOptionalObj(*extensionsObj, GLTFExtensionKHRLightsPunctual);
      if (lightsPunctualObj) {
        decodeArrayWithMapElem<KHRLight>(*lightsPunctualObj, "lights",
                                         data.lights,
                                         [this](const nlohmann::json &item) {
                                           return decodeKHRLight(item);
                                         });
      }

      decodeObjWithMap<VRMVrm>(
          *extensionsObj, GLTFExtensionVRM, data.vrm0,
          [this](const nlohmann::json &item) { return decodeVRMVrm(item); });

      decodeObjWithMap<VRMCVrm>(
          *extensionsObj, GLTFExtensionVRMCvrm, data.vrm1,
          [this](const nlohmann::json &item) { return decodeVRMCVrm(item); });
    }

    popStack();

    return data;
  }

#pragma mark - draco

  GLTFMeshPrimitiveDracoExtension
  decodeMeshPrimitiveDracoExtension(const nlohmann::json &j) {
    GLTFMeshPrimitiveDracoExtension dracoExtension;
    decodeValue(j, "bufferView", dracoExtension.bufferView);
    decodeObjWithMap<GLTFMeshPrimitiveAttributes>(
        j, "attributes", dracoExtension.attributes,
        [this](const nlohmann::json &value) {
          return decodeMeshPrimitiveAttributes(value);
        });
    return dracoExtension;
  }

#pragma mark - KHR

  KHRTextureTransform decodeKHRTextureTransform(const nlohmann::json &j) {
    KHRTextureTransform t;
    decodeValueWithMap<std::array<float, 2>>(
        j, "offset", t.offset, [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 2>>();
        });
    decodeValue(j, "rotation", t.rotation);
    decodeValueWithMap<std::array<float, 2>>(
        j, "scale", t.scale, [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 2>>();
        });
    decodeValue(j, "texCoord", t.texCoord);
    return t;
  }

  KHRMaterialAnisotropy decodeKHRMaterialAnisotropy(const nlohmann::json &j) {
    KHRMaterialAnisotropy anisotropy;
    decodeValue(j, "anisotropyStrength", anisotropy.anisotropyStrength);
    decodeValue(j, "anisotropyRotation", anisotropy.anisotropyRotation);
    decodeObjWithMap<GLTFTextureInfo>(j, "anisotropyTexture",
                                      anisotropy.anisotropyTexture,
                                      [this](const nlohmann::json &value) {
                                        return decodeTextureInfo(value);
                                      });
    return anisotropy;
  }

  KHRMaterialClearcoat decodeKHRMaterialClearcoat(const nlohmann::json &j) {
    KHRMaterialClearcoat clearcoat;
    decodeValue(j, "clearcoatFactor", clearcoat.clearcoatFactor);
    decodeObjWithMap<GLTFTextureInfo>(j, "clearcoatTexture",
                                      clearcoat.clearcoatTexture,
                                      [this](const nlohmann::json &value) {
                                        return decodeTextureInfo(value);
                                      });
    decodeValue(j, "clearcoatRoughnessFactor",
                clearcoat.clearcoatRoughnessFactor);
    decodeObjWithMap<GLTFTextureInfo>(j, "clearcoatRoughnessTexture",
                                      clearcoat.clearcoatRoughnessTexture,
                                      [this](const nlohmann::json &value) {
                                        return decodeTextureInfo(value);
                                      });
    decodeObjWithMap<GLTFMaterialNormalTextureInfo>(
        j, "clearcoatNormalTexture", clearcoat.clearcoatNormalTexture,
        [this](const nlohmann::json &value) {
          return decodeMaterialNormalTextureInfo(value);
        });
    return clearcoat;
  }

  KHRMaterialDispersion decodeKHRMaterialDispersion(const nlohmann::json &j) {
    KHRMaterialDispersion dispersion;
    decodeValue(j, "dispersion", dispersion.dispersion);
    return dispersion;
  }

  KHRMaterialEmissiveStrength
  decodeKHRMaterialEmissiveStrength(const nlohmann::json &j) {
    KHRMaterialEmissiveStrength strength;
    decodeValue(j, "emissiveStrength", strength.emissiveStrength);
    return strength;
  }

  KHRMaterialIor decodeKHRMaterialIor(const nlohmann::json &j) {
    KHRMaterialIor ior;
    decodeValue(j, "ior", ior.ior);
    return ior;
  }

  KHRMaterialIridescence decodeKHRMaterialIridescence(const nlohmann::json &j) {
    KHRMaterialIridescence iridescence;
    decodeValue(j, "iridescenceFactor", iridescence.iridescenceFactor);
    decodeObjWithMap<GLTFTextureInfo>(j, "iridescenceTexture",
                                      iridescence.iridescenceTexture,
                                      [this](const nlohmann::json &value) {
                                        return decodeTextureInfo(value);
                                      });
    decodeValue(j, "iridescenceIor", iridescence.iridescenceIor);
    decodeValue(j, "iridescenceThicknessMinimum",
                iridescence.iridescenceThicknessMinimum);
    decodeValue(j, "iridescenceThicknessMaximum",
                iridescence.iridescenceThicknessMaximum);
    decodeObjWithMap<GLTFTextureInfo>(j, "iridescenceThicknessTexture",
                                      iridescence.iridescenceThicknessTexture,
                                      [this](const nlohmann::json &value) {
                                        return decodeTextureInfo(value);
                                      });
    return iridescence;
  }

  KHRMaterialSheen decodeKHRMaterialSheen(const nlohmann::json &j) {
    KHRMaterialSheen sheen;
    decodeValueWithMap<std::array<float, 3>>(
        j, "sheenColorFactor", sheen.sheenColorFactor,
        [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 3>>();
        });
    decodeObjWithMap<GLTFTextureInfo>(j, "sheenColorTexture",
                                      sheen.sheenColorTexture,
                                      [this](const nlohmann::json &value) {
                                        return decodeTextureInfo(value);
                                      });
    decodeValue(j, "sheenRoughnessFactor", sheen.sheenRoughnessFactor);
    decodeObjWithMap<GLTFTextureInfo>(j, "sheenRoughnessTexture",
                                      sheen.sheenRoughnessTexture,
                                      [this](const nlohmann::json &value) {
                                        return decodeTextureInfo(value);
                                      });
    return sheen;
  }

  KHRMaterialSpecular decodeKHRMaterialSpecular(const nlohmann::json &j) {
    KHRMaterialSpecular specular;
    decodeValue(j, "specularFactor", specular.specularFactor);
    decodeObjWithMap<GLTFTextureInfo>(j, "specularTexture",
                                      specular.specularTexture,
                                      [this](const nlohmann::json &value) {
                                        return decodeTextureInfo(value);
                                      });
    decodeValueWithMap<std::array<float, 3>>(
        j, "specularColorFactor", specular.specularColorFactor,
        [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 3>>();
        });
    decodeObjWithMap<GLTFTextureInfo>(j, "specularColorTexture",
                                      specular.specularColorTexture,
                                      [this](const nlohmann::json &value) {
                                        return decodeTextureInfo(value);
                                      });
    return specular;
  }

  KHRMaterialTransmission
  decodeKHRMaterialTransmission(const nlohmann::json &j) {
    KHRMaterialTransmission transmission;
    decodeValue(j, "transmissionFactor", transmission.transmissionFactor);
    decodeObjWithMap<GLTFTextureInfo>(j, "transmissionTexture",
                                      transmission.transmissionTexture,
                                      [this](const nlohmann::json &value) {
                                        return decodeTextureInfo(value);
                                      });
    return transmission;
  }

  KHRMaterialVolume decodeKHRMaterialVolume(const nlohmann::json &j) {
    KHRMaterialVolume volume;
    decodeValue(j, "thicknessFactor", volume.thicknessFactor);
    decodeObjWithMap<GLTFTextureInfo>(j, "thicknessTexture",
                                      volume.thicknessTexture,
                                      [this](const nlohmann::json &value) {
                                        return decodeTextureInfo(value);
                                      });
    decodeValue(j, "attenuationDistance", volume.attenuationDistance);
    decodeValueWithMap<std::array<float, 3>>(
        j, "attenuationColor", volume.attenuationColor,
        [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 3>>();
        });
    return volume;
  }

  KHRLightSpot decodeKHRLightSpot(const nlohmann::json &j) {
    KHRLightSpot spot;
    decodeValue(j, "innerConeAngle", spot.innerConeAngle);
    decodeValue(j, "outerConeAngle", spot.outerConeAngle);
    return spot;
  }

  KHRLight decodeKHRLight(const nlohmann::json &j) {
    KHRLight light;
    decodeValue(j, "name", light.name);
    decodeValueWithMap<std::array<float, 3>>(
        j, "color", light.color, [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 3>>();
        });
    decodeValue(j, "intensity", light.intensity);
    decodeEnumValue<KHRLight::Type>(j, "type", light.type,
                                    KHRLight::TypeFromString);
    if (light.type == KHRLight::Type::SPOT) {
      decodeObjWithMap<KHRLightSpot>(j, "spot", light.spot,
                                     [this](const nlohmann::json &value) {
                                       return decodeKHRLightSpot(value);
                                     });
    }
    return light;
  }

#pragma mark - VRM 1

  VRMCMeta decodeVRMCMeta(const nlohmann::json &j) {
    VRMCMeta meta;
    decodeValue(j, "name", meta.name);
    decodeValue(j, "version", meta.version);
    decodeValue(j, "authors", meta.authors);
    decodeValue(j, "copyrightInformation", meta.copyrightInformation);
    decodeValue(j, "contactInformation", meta.contactInformation);
    decodeValue(j, "references", meta.references);
    decodeValue(j, "thirdPartyLicenses", meta.thirdPartyLicenses);
    decodeValue(j, "thumbnailImage", meta.thumbnailImage);
    decodeValue(j, "licenseUrl", meta.licenseUrl);
    decodeEnumValue<VRMCMeta::AvatarPermission>(
        j, "avatarPermission", meta.avatarPermission,
        VRMCMeta::AvatarPermissionFromString);
    decodeValue(j, "allowExcessivelyViolentUsage",
                meta.allowExcessivelyViolentUsage);
    decodeValue(j, "allowExcessivelySexualUsage",
                meta.allowExcessivelySexualUsage);
    decodeEnumValue<VRMCMeta::CommercialUsage>(
        j, "commercialUsage", meta.commercialUsage,
        VRMCMeta::CommercialUsageFromString);
    decodeValue(j, "allowPoliticalOrReligiousUsage",
                meta.allowPoliticalOrReligiousUsage);
    decodeValue(j, "allowAntisocialOrHateUsage",
                meta.allowAntisocialOrHateUsage);
    decodeEnumValue<VRMCMeta::CreditNotation>(
        j, "creditNotation", meta.creditNotation,
        VRMCMeta::CreditNotationFromString);
    decodeValue(j, "allowRedistribution", meta.allowRedistribution);
    decodeEnumValue<VRMCMeta::Modification>(
        j, "modification", meta.modification, VRMCMeta::ModificationFromString);
    decodeValue(j, "otherLicenseUrl", meta.otherLicenseUrl);
    return meta;
  }

  VRMCHumanBone decodeVRMCHumanBone(const nlohmann::json &j) {
    VRMCHumanBone bone;
    decodeValue(j, "node", bone.node);
    return bone;
  }

  VRMCHumanBones decodeVRMCHumanBones(const nlohmann::json &j) {
    VRMCHumanBones bones;
    decodeObjWithMap<VRMCHumanBone>(j, "hips", bones.hips,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "spine", bones.spine,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "chest", bones.chest,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "upperChest", bones.upperChest,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "neck", bones.neck,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "head", bones.head,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftEye", bones.leftEye,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightEye", bones.rightEye,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "jaw", bones.jaw,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftUpperLeg", bones.leftUpperLeg,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftLowerLeg", bones.leftLowerLeg,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftFoot", bones.leftFoot,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftToes", bones.leftToes,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightUpperLeg", bones.rightUpperLeg,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightLowerLeg", bones.rightLowerLeg,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightFoot", bones.rightFoot,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightToes", bones.rightToes,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftShoulder", bones.leftShoulder,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftUpperArm", bones.leftUpperArm,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftLowerArm", bones.leftLowerArm,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftHand", bones.leftHand,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightShoulder", bones.rightShoulder,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightUpperArm", bones.rightUpperArm,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightLowerArm", bones.rightLowerArm,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightHand", bones.rightHand,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftThumbMetacarpal",
                                    bones.leftThumbMetacarpal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftThumbProximal",
                                    bones.leftThumbProximal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftThumbDistal", bones.leftThumbDistal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftIndexProximal",
                                    bones.leftIndexProximal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftIndexIntermediate",
                                    bones.leftIndexIntermediate,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftIndexDistal", bones.leftIndexDistal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftMiddleProximal",
                                    bones.leftMiddleProximal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftMiddleIntermediate",
                                    bones.leftMiddleIntermediate,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftMiddleDistal",
                                    bones.leftMiddleDistal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftRingProximal",
                                    bones.leftRingProximal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftRingIntermediate",
                                    bones.leftRingIntermediate,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftRingDistal", bones.leftRingDistal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftLittleProximal",
                                    bones.leftLittleProximal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftLittleIntermediate",
                                    bones.leftLittleIntermediate,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "leftLittleDistal",
                                    bones.leftLittleDistal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightThumbMetacarpal",
                                    bones.rightThumbMetacarpal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightThumbProximal",
                                    bones.rightThumbProximal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightThumbDistal",
                                    bones.rightThumbDistal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightIndexProximal",
                                    bones.rightIndexProximal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightIndexIntermediate",
                                    bones.rightIndexIntermediate,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightIndexDistal",
                                    bones.rightIndexDistal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightMiddleProximal",
                                    bones.rightMiddleProximal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightMiddleIntermediate",
                                    bones.rightMiddleIntermediate,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightMiddleDistal",
                                    bones.rightMiddleDistal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightRingProximal",
                                    bones.rightRingProximal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightRingIntermediate",
                                    bones.rightRingIntermediate,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightRingDistal", bones.rightRingDistal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightLittleProximal",
                                    bones.rightLittleProximal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightLittleIntermediate",
                                    bones.rightLittleIntermediate,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    decodeObjWithMap<VRMCHumanBone>(j, "rightLittleDistal",
                                    bones.rightLittleDistal,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMCHumanBone(value);
                                    });
    return bones;
  }

  VRMCHumanoid decodeVRMCHumanoid(const nlohmann::json &j) {
    VRMCHumanoid humanoid;
    decodeObjWithMap<VRMCHumanBones>(j, "humanBones", humanoid.humanBones,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRMCHumanBones(value);
                                     });
    return humanoid;
  }

  VRMCFirstPersonMeshAnnotation
  decodeVRMCFirstPersonMeshAnnotation(const nlohmann::json &j) {
    VRMCFirstPersonMeshAnnotation annotation;
    decodeValue(j, "node", annotation.node);
    decodeEnumValue<VRMCFirstPersonMeshAnnotation::Type>(
        j, "type", annotation.type,
        VRMCFirstPersonMeshAnnotation::TypeFromString);
    return annotation;
  }

  VRMCFirstPerson decodeVRMCFirstPerson(const nlohmann::json &j) {
    VRMCFirstPerson firstPerson;
    decodeArrayWithMapElem<VRMCFirstPersonMeshAnnotation>(
        j, "meshAnnotations", firstPerson.meshAnnotations,
        [this](const nlohmann::json &item) {
          return decodeVRMCFirstPersonMeshAnnotation(item);
        });
    return firstPerson;
  }

  VRMCLookAtRangeMap decodeVRMCLookAtRangeMap(const nlohmann::json &j) {
    VRMCLookAtRangeMap rangeMap;
    decodeValue(j, "inputMaxValue", rangeMap.inputMaxValue);
    decodeValue(j, "outputScale", rangeMap.outputScale);
    return rangeMap;
  }

  VRMCLookAt decodeVRMCLookAt(const nlohmann::json &j) {
    VRMCLookAt lookAt;
    decodeValueWithMap<std::array<float, 3>>(
        j, "offsetFromHeadBone", lookAt.offsetFromHeadBone,
        [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 3>>();
        });
    decodeEnumValue<VRMCLookAt::Type>(j, "type", lookAt.type,
                                      VRMCLookAt::TypeFromString);

    decodeObjWithMap<VRMCLookAtRangeMap>(
        j, "rangeMapHorizontalInner", lookAt.rangeMapHorizontalInner,
        [this](const nlohmann::json &value) {
          return decodeVRMCLookAtRangeMap(value);
        });
    decodeObjWithMap<VRMCLookAtRangeMap>(
        j, "rangeMapHorizontalOuter", lookAt.rangeMapHorizontalOuter,
        [this](const nlohmann::json &value) {
          return decodeVRMCLookAtRangeMap(value);
        });
    decodeObjWithMap<VRMCLookAtRangeMap>(
        j, "rangeMapVerticalDown", lookAt.rangeMapVerticalDown,
        [this](const nlohmann::json &value) {
          return decodeVRMCLookAtRangeMap(value);
        });
    decodeObjWithMap<VRMCLookAtRangeMap>(
        j, "rangeMapVerticalUp", lookAt.rangeMapVerticalUp,
        [this](const nlohmann::json &value) {
          return decodeVRMCLookAtRangeMap(value);
        });
    return lookAt;
  }

  VRMCExpressionMaterialColorBind
  decodeVRMCExpressionMaterialColorBind(const nlohmann::json &j) {
    VRMCExpressionMaterialColorBind bind;
    decodeValue(j, "material", bind.material);
    decodeEnumValue<VRMCExpressionMaterialColorBind::Type>(
        j, "type", bind.type, VRMCExpressionMaterialColorBind::TypeFromString);
    decodeValueWithMap<std::array<float, 4>>(
        j, "targetValue", bind.targetValue,
        [this](const nlohmann::json &value) {
          if (!value.is_array() || value.size() != 4)
            throw InvalidFormatException(context());
          return value.get<std::array<float, 4>>();
        });
    return bind;
  }

  VRMCExpressionMorphTargetBind
  decodeVRMCExpressionMorphTargetBind(const nlohmann::json &j) {
    VRMCExpressionMorphTargetBind bind;
    decodeValue(j, "node", bind.node);
    decodeValue(j, "index", bind.index);
    decodeValue(j, "weight", bind.weight);
    return bind;
  }

  VRMCExpressionTextureTransformBind
  decodeVRMCExpressionTextureTransformBind(const nlohmann::json &j) {
    VRMCExpressionTextureTransformBind bind;
    decodeValue(j, "material", bind.material);
    decodeValueWithMap<std::array<float, 2>>(
        j, "scale", bind.scale, [this](const nlohmann::json &value) {
          if (!value.is_array() || value.size() != 2)
            throw InvalidFormatException(context());
          return value.get<std::array<float, 2>>();
        });
    decodeValueWithMap<std::array<float, 2>>(
        j, "offset", bind.offset, [this](const nlohmann::json &value) {
          if (!value.is_array() || value.size() != 2)
            throw InvalidFormatException(context());
          return value.get<std::array<float, 2>>();
        });
    return bind;
  }

  VRMCExpression decodeVRMCExpression(const nlohmann::json &j) {
    VRMCExpression expression;

    decodeArrayWithMapElem<VRMCExpressionMorphTargetBind>(
        j, "morphTargetBinds", expression.morphTargetBinds,
        [this](const nlohmann::json &item) {
          return decodeVRMCExpressionMorphTargetBind(item);
        });

    decodeArrayWithMapElem<VRMCExpressionMaterialColorBind>(
        j, "materialColorBinds", expression.materialColorBinds,
        [this](const nlohmann::json &item) {
          return decodeVRMCExpressionMaterialColorBind(item);
        });

    decodeArrayWithMapElem<VRMCExpressionTextureTransformBind>(
        j, "textureTransformBinds", expression.textureTransformBinds,
        [this](const nlohmann::json &item) {
          return decodeVRMCExpressionTextureTransformBind(item);
        });

    decodeValue(j, "isBinary", expression.isBinary);
    decodeEnumValue<VRMCExpression::Override>(
        j, "overrideBlink", expression.overrideBlink,
        VRMCExpression::OverrideFromString);
    decodeEnumValue<VRMCExpression::Override>(
        j, "overrideLookAt", expression.overrideLookAt,
        VRMCExpression::OverrideFromString);
    decodeEnumValue<VRMCExpression::Override>(
        j, "overrideMouth", expression.overrideMouth,
        VRMCExpression::OverrideFromString);

    return expression;
  }

  VRMCExpressionsPreset decodeVRMCExpressionsPreset(const nlohmann::json &j) {
    VRMCExpressionsPreset preset;
    decodeObjWithMap<VRMCExpression>(j, "happy", preset.happy,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRMCExpression(value);
                                     });
    decodeObjWithMap<VRMCExpression>(j, "angry", preset.angry,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRMCExpression(value);
                                     });
    decodeObjWithMap<VRMCExpression>(j, "sad", preset.sad,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRMCExpression(value);
                                     });
    decodeObjWithMap<VRMCExpression>(j, "relaxed", preset.relaxed,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRMCExpression(value);
                                     });
    decodeObjWithMap<VRMCExpression>(j, "surprised", preset.surprised,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRMCExpression(value);
                                     });
    decodeObjWithMap<VRMCExpression>(j, "aa", preset.aa,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRMCExpression(value);
                                     });
    decodeObjWithMap<VRMCExpression>(j, "ih", preset.ih,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRMCExpression(value);
                                     });
    decodeObjWithMap<VRMCExpression>(j, "ou", preset.ou,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRMCExpression(value);
                                     });
    decodeObjWithMap<VRMCExpression>(j, "ee", preset.ee,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRMCExpression(value);
                                     });
    decodeObjWithMap<VRMCExpression>(j, "oh", preset.oh,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRMCExpression(value);
                                     });
    decodeObjWithMap<VRMCExpression>(j, "blink", preset.blink,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRMCExpression(value);
                                     });
    decodeObjWithMap<VRMCExpression>(j, "blinkLeft", preset.blinkLeft,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRMCExpression(value);
                                     });
    decodeObjWithMap<VRMCExpression>(j, "blinkRight", preset.blinkRight,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRMCExpression(value);
                                     });
    decodeObjWithMap<VRMCExpression>(j, "lookUp", preset.lookUp,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRMCExpression(value);
                                     });
    decodeObjWithMap<VRMCExpression>(j, "lookDown", preset.lookDown,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRMCExpression(value);
                                     });
    decodeObjWithMap<VRMCExpression>(j, "lookLeft", preset.lookLeft,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRMCExpression(value);
                                     });
    decodeObjWithMap<VRMCExpression>(j, "lookRight", preset.lookRight,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRMCExpression(value);
                                     });
    decodeObjWithMap<VRMCExpression>(j, "neutral", preset.neutral,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRMCExpression(value);
                                     });
    return preset;
  }

  VRMCExpressions decodeVRMCExpressions(const nlohmann::json &j) {
    VRMCExpressions expressions;
    decodeObjWithMap<VRMCExpressionsPreset>(
        j, "preset", expressions.preset, [this](const nlohmann::json &value) {
          return decodeVRMCExpressionsPreset(value);
        });
    auto customObj = decodeOptionalObj(j, "custom");
    if (customObj) {
      std::map<std::string, VRMCExpression> custom;
      for (const auto &item : customObj->items()) {
        custom[item.key()] = decodeVRMCExpression(item.value());
      }
      expressions.custom = custom;
    }
    return expressions;
  }

  VRMCVrm decodeVRMCVrm(const nlohmann::json &j) {
    VRMCVrm vrm;
    decodeValue(j, "specVersion", vrm.specVersion);
    decodeObjWithMap<VRMCMeta>(
        j, "meta", vrm.meta,
        [this](const nlohmann::json &value) { return decodeVRMCMeta(value); });
    decodeObjWithMap<VRMCHumanoid>(j, "humanoid", vrm.humanoid,
                                   [this](const nlohmann::json &value) {
                                     return decodeVRMCHumanoid(value);
                                   });
    decodeObjWithMap<VRMCFirstPerson>(j, "firstPerson", vrm.firstPerson,
                                      [this](const nlohmann::json &value) {
                                        return decodeVRMCFirstPerson(value);
                                      });
    decodeObjWithMap<VRMCLookAt>(j, "lookAt", vrm.lookAt,
                                 [this](const nlohmann::json &value) {
                                   return decodeVRMCLookAt(value);
                                 });
    decodeObjWithMap<VRMCExpressions>(j, "expressions", vrm.expressions,
                                      [this](const nlohmann::json &value) {
                                        return decodeVRMCExpressions(value);
                                      });

    return vrm;
  }

#pragma mark - VRM 0

  VRMVrm decodeVRMVrm(const nlohmann::json &j) {
    VRMVrm vrm;
    decodeValue(j, "exporterVersion", vrm.exporterVersion);
    decodeValue(j, "specVersion", vrm.specVersion);
    decodeObjWithMap<VRMMeta>(
        j, "meta", vrm.meta,
        [this](const nlohmann::json &value) { return decodeVRMMeta(value); });
    decodeObjWithMap<VRMHumanoid>(j, "humanoid", vrm.humanoid,
                                  [this](const nlohmann::json &value) {
                                    return decodeVRMHumanoid(value);
                                  });
    decodeObjWithMap<VRMFirstPerson>(j, "firstPerson", vrm.firstPerson,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRMFirstPerson(value);
                                     });
    decodeObjWithMap<VRMBlendShape>(j, "blendShapeMaster", vrm.blendShapeMaster,
                                    [this](const nlohmann::json &value) {
                                      return decodeVRMBlendShape(value);
                                    });
    decodeObjWithMap<VRMSecondaryAnimation>(
        j, "secondaryAnimation", vrm.secondaryAnimation,
        [this](const nlohmann::json &value) {
          return decodeVRMSecondaryAnimation(value);
        });
    decodeArrayWithMapElem<VRMMaterial>(
        j, "materialProperties", vrm.materialProperties,
        [this](const nlohmann::json &item) { return decodeVRMMaterial(item); });
    return vrm;
  }

  VRMMeta decodeVRMMeta(const nlohmann::json &j) {
    VRMMeta meta;
    decodeValue(j, "title", meta.title);
    decodeValue(j, "version", meta.version);
    decodeValue(j, "author", meta.author);
    decodeValue(j, "contactInformation", meta.contactInformation);
    decodeValue(j, "reference", meta.reference);
    decodeValue(j, "texture", meta.texture);
    decodeEnumValue<VRMMeta::AllowedUserName>(
        j, "allowedUserName", meta.allowedUserName,
        VRMMeta::AllowedUserNameFromString);
    decodeEnumValue<VRMMeta::UsagePermission>(
        j, "violentUssageName", meta.violentUsage,
        VRMMeta::UsagePermissionFromString);
    decodeEnumValue<VRMMeta::UsagePermission>(
        j, "sexualUssageName", meta.sexualUsage,
        VRMMeta::UsagePermissionFromString);
    decodeEnumValue<VRMMeta::UsagePermission>(
        j, "commercialUssageName", meta.commercialUsage,
        VRMMeta::UsagePermissionFromString);
    decodeValue(j, "otherPermissionUrl", meta.otherPermissionUrl);
    decodeEnumValue<VRMMeta::LicenseName>(j, "licenseName", meta.licenseName,
                                          VRMMeta::LicenseNameFromString);
    decodeValue(j, "otherLicenseUrl", meta.otherLicenseUrl);
    return meta;
  }

  VRMHumanoid decodeVRMHumanoid(const nlohmann::json &j) {
    VRMHumanoid humanoid;
    decodeArrayWithMapElem<VRMHumanoidBone>(
        j, "humanBones", humanoid.humanBones,
        [this](const nlohmann::json &item) {
          return decodeVRMHumanoidBone(item);
        });
    decodeValue(j, "armStretch", humanoid.armStretch);
    decodeValue(j, "legStretch", humanoid.legStretch);
    decodeValue(j, "upperArmTwist", humanoid.upperArmTwist);
    decodeValue(j, "lowerArmTwist", humanoid.lowerArmTwist);
    decodeValue(j, "upperLegTwist", humanoid.upperLegTwist);
    decodeValue(j, "lowerLegTwist", humanoid.lowerLegTwist);
    decodeValue(j, "feetSpacing", humanoid.feetSpacing);
    decodeValue(j, "hasTranslationDoF", humanoid.hasTranslationDoF);
    return humanoid;
  }

  VRMHumanoidBone decodeVRMHumanoidBone(const nlohmann::json &j) {
    VRMHumanoidBone bone;
    decodeEnumValue<VRMHumanoidBone::Bone>(j, "bone", bone.bone,
                                           VRMHumanoidBone::BoneFromString);
    decodeValue(j, "node", bone.node);
    decodeValue(j, "useDefaultValues", bone.useDefaultValues);
    decodeObjWithMap<VRMVec3>(
        j, "min", bone.min,
        [this](const nlohmann::json &item) { return decodeVRMVec3(item); });
    decodeObjWithMap<VRMVec3>(
        j, "max", bone.max,
        [this](const nlohmann::json &item) { return decodeVRMVec3(item); });
    decodeObjWithMap<VRMVec3>(
        j, "center", bone.center,
        [this](const nlohmann::json &item) { return decodeVRMVec3(item); });
    decodeValue(j, "axisLength", bone.axisLength);
    return bone;
  }

  VRMVec3 decodeVRMVec3(const nlohmann::json &j) {
    VRMVec3 vec;
    decodeValue(j, "x", vec.x);
    decodeValue(j, "y", vec.y);
    decodeValue(j, "z", vec.z);
    return vec;
  }

  VRMMeshAnnotation decodeVRMMeshAnnotation(const nlohmann::json &j) {
    VRMMeshAnnotation annotation;
    decodeValue(j, "mesh", annotation.mesh);
    decodeValue(j, "firstPersonFlag", annotation.firstPersonFlag);
    return annotation;
  }

  VRMDegreeMap decodeVRMDegreeMap(const nlohmann::json &j) {
    VRMDegreeMap degreeMap;
    decodeValue(j, "curve", degreeMap.curve);
    decodeValue(j, "xRange", degreeMap.xRange);
    decodeValue(j, "yRange", degreeMap.yRange);
    return degreeMap;
  }

  VRMFirstPerson decodeVRMFirstPerson(const nlohmann::json &j) {
    VRMFirstPerson firstPerson;
    decodeValue(j, "firstPersonBone", firstPerson.firstPersonBone);
    decodeObjWithMap<VRMVec3>(
        j, "firstPersonBoneOffset", firstPerson.firstPersonBoneOffset,
        [this](const nlohmann::json &item) { return decodeVRMVec3(item); });
    decodeArrayWithMapElem<VRMMeshAnnotation>(
        j, "meshAnnotations", firstPerson.meshAnnotations,
        [this](const nlohmann::json &item) {
          return decodeVRMMeshAnnotation(item);
        });
    decodeValue(j, "lookAtTypeName", firstPerson.lookAtTypeName);
    decodeObjWithMap<VRMDegreeMap>(j, "lookAtHorizontalInner",
                                   firstPerson.lookAtHorizontalInner,
                                   [this](const nlohmann::json &item) {
                                     return decodeVRMDegreeMap(item);
                                   });
    decodeObjWithMap<VRMDegreeMap>(j, "lookAtHorizontalOuter",
                                   firstPerson.lookAtHorizontalOuter,
                                   [this](const nlohmann::json &item) {
                                     return decodeVRMDegreeMap(item);
                                   });
    decodeObjWithMap<VRMDegreeMap>(j, "lookAtVerticalDown",
                                   firstPerson.lookAtVerticalDown,
                                   [this](const nlohmann::json &item) {
                                     return decodeVRMDegreeMap(item);
                                   });
    decodeObjWithMap<VRMDegreeMap>(j, "lookAtVerticalUp",
                                   firstPerson.lookAtVerticalUp,
                                   [this](const nlohmann::json &item) {
                                     return decodeVRMDegreeMap(item);
                                   });
    return firstPerson;
  }

  VRMBlendShapeMaterialBind
  decodeVRMBlendShapeMaterialBind(const nlohmann::json &j) {
    VRMBlendShapeMaterialBind materialBind;
    decodeValue(j, "materialName", materialBind.materialName);
    decodeValue(j, "propertyName", materialBind.propertyName);
    decodeValue(j, "targetValue", materialBind.targetValue);
    return materialBind;
  }

  VRMBlendShape decodeVRMBlendShape(const nlohmann::json &j) {
    VRMBlendShape blendShape;
    decodeArrayWithMapElem<VRMBlendShapeGroup>(
        j, "blendShapeGroups", blendShape.blendShapeGroups,
        [this](const nlohmann::json &item) {
          return decodeVRMBlendShapeGroup(item);
        });
    return blendShape;
  }

  VRMBlendShapeBind decodeVRMBlendShapeBind(const nlohmann::json &j) {
    VRMBlendShapeBind bind;
    decodeValue(j, "mesh", bind.mesh);
    decodeValue(j, "index", bind.index);
    decodeValue(j, "weight", bind.weight);
    return bind;
  }

  VRMBlendShapeGroup decodeVRMBlendShapeGroup(const nlohmann::json &j) {
    VRMBlendShapeGroup blendShapeGroup;
    decodeValue(j, "name", blendShapeGroup.name);
    decodeEnumValue<VRMBlendShapeGroup::PresetName>(
        j, "presetName", blendShapeGroup.presetName,
        VRMBlendShapeGroup::PresetNameFromString);
    decodeArrayWithMapElem<VRMBlendShapeBind>(
        j, "binds", blendShapeGroup.binds, [this](const nlohmann::json &item) {
          return decodeVRMBlendShapeBind(item);
        });
    decodeArrayWithMapElem<VRMBlendShapeMaterialBind>(
        j, "materialValues", blendShapeGroup.materialValues,
        [this](const nlohmann::json &item) {
          return decodeVRMBlendShapeMaterialBind(item);
        });
    decodeValue(j, "isBinary", blendShapeGroup.isBinary);
    return blendShapeGroup;
  }

  VRMSecondaryAnimationCollider
  decodeVRMSecondaryAnimationCollider(const nlohmann::json &j) {
    VRMSecondaryAnimationCollider collider;
    decodeObjWithMap<VRMVec3>(
        j, "offset", collider.offset,
        [this](const nlohmann::json &item) { return decodeVRMVec3(item); });
    decodeValue(j, "radius", collider.radius);
    return collider;
  }

  VRMSecondaryAnimationColliderGroup
  decodeVRMSecondaryAnimationColliderGroup(const nlohmann::json &j) {
    VRMSecondaryAnimationColliderGroup colliderGroup;
    decodeValue(j, "node", colliderGroup.node);
    decodeArrayWithMapElem<VRMSecondaryAnimationCollider>(
        j, "colliders", colliderGroup.colliders,
        [this](const nlohmann::json &item) {
          return decodeVRMSecondaryAnimationCollider(item);
        });
    return colliderGroup;
  }

  VRMSecondaryAnimationSpring
  decodeVRMSecondaryAnimationSpring(const nlohmann::json &j) {
    VRMSecondaryAnimationSpring spring;
    decodeValue(j, "comment", spring.comment);
    decodeValue(j, "stiffiness", spring.stiffiness);
    decodeValue(j, "gravityPower", spring.gravityPower);
    decodeObjWithMap<VRMVec3>(
        j, "gravityDir", spring.gravityDir,
        [this](const nlohmann::json &item) { return decodeVRMVec3(item); });
    decodeValue(j, "dragForce", spring.dragForce);
    decodeValue(j, "center", spring.center);
    decodeValue(j, "hitRadius", spring.hitRadius);
    decodeValue(j, "bones", spring.bones);
    decodeValue(j, "colliderGroups", spring.colliderGroups);
    return spring;
  }

  VRMSecondaryAnimation decodeVRMSecondaryAnimation(const nlohmann::json &j) {
    VRMSecondaryAnimation secondaryAnimation;
    decodeArrayWithMapElem<VRMSecondaryAnimationSpring>(
        j, "boneGroups", secondaryAnimation.boneGroups,
        [this](const nlohmann::json &item) {
          return decodeVRMSecondaryAnimationSpring(item);
        });
    decodeArrayWithMapElem<VRMSecondaryAnimationColliderGroup>(
        j, "colliderGroups", secondaryAnimation.colliderGroups,
        [this](const nlohmann::json &item) {
          return decodeVRMSecondaryAnimationColliderGroup(item);
        });
    return secondaryAnimation;
  }

  template <typename T>
  std::map<std::string, T> decodeKeyedMapValue(const nlohmann::json &obj) {
    std::map<std::string, T> map;
    for (auto it = obj.begin(); it != obj.end(); ++it) {
      const auto key = it.key();
      decodeValue(obj, key, map[key]);
    }
    return map;
  }

  VRMMaterial decodeVRMMaterial(const nlohmann::json &j) {
    VRMMaterial material;
    decodeValue(j, "name", material.name);
    decodeValue(j, "shader", material.shader);
    decodeValue(j, "renderQueue", material.renderQueue);
    decodeObjWithMap<std::map<std::string, float>>(
        j, "floatProperties", material.floatProperties,
        [this](const nlohmann::json &obj) {
          return decodeKeyedMapValue<float>(obj);
        });
    decodeObjWithMap<std::map<std::string, std::vector<float>>>(
        j, "vectorProperties", material.vectorProperties,
        [this](const nlohmann::json &obj) {
          return decodeKeyedMapValue<std::vector<float>>(obj);
        });
    decodeObjWithMap<std::map<std::string, uint32_t>>(
        j, "textureProperties", material.textureProperties,
        [this](const nlohmann::json &obj) {
          return decodeKeyedMapValue<uint32_t>(obj);
        });
    decodeObjWithMap<std::map<std::string, bool>>(
        j, "keywordMap", material.keywordMap,
        [this](const nlohmann::json &obj) {
          return decodeKeyedMapValue<bool>(obj);
        });
    decodeObjWithMap<std::map<std::string, std::string>>(
        j, "tagMap", material.tagMap, [this](const nlohmann::json &obj) {
          return decodeKeyedMapValue<std::string>(obj);
        });
    return material;
  }
};

} // namespace gltf2

#endif /* GLTFJsonDecoder_h */
