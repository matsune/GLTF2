#ifndef JsonDecoder_h
#define JsonDecoder_h

#include "GLTFException.h"
#include "GLTFExtension.h"
#include "Json.h"
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

template <> bool isValueType<int>(const nlohmann::json &j) {
  return j.is_number_integer();
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
namespace json {

class JsonDecoder {
public:
  static Json decode(const nlohmann::json &j) {
    return JsonDecoder().decodeJson(j);
  }

  JsonDecoder(const JsonDecoder &) = delete;
  JsonDecoder &operator=(const JsonDecoder &) = delete;

  std::stack<std::string> stack;

  JsonDecoder(){};

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
   * must be compatible with the types nlohmann::get<T>() supports.
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
   * type must be compatible with the nlohmann::get<T>() operation, as it
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

  AccessorSparseIndices decodeAccessorSparseIndices(const nlohmann::json &j) {
    AccessorSparseIndices indices;
    decodeValue(j, "bufferView", indices.bufferView);
    decodeValue(j, "byteOffset", indices.byteOffset);

    decodeEnumValue<AccessorSparseIndices::ComponentType>(
        j, "componentType", indices.componentType,
        AccessorSparseIndices::ComponentTypeFromInt);
    return indices;
  }

  AccessorSparseValues decodeAccessorSparseValues(const nlohmann::json &j) {
    AccessorSparseValues values;
    decodeValue(j, "bufferView", values.bufferView);
    decodeValue(j, "byteOffset", values.byteOffset);
    return values;
  }

  AccessorSparse decodeAccessorSparse(const nlohmann::json &j) {
    AccessorSparse sparse;
    decodeValue(j, "count", sparse.count);
    decodeObjWithMap<AccessorSparseIndices>(
        j, "indices", sparse.indices, [this](const nlohmann::json &value) {
          return decodeAccessorSparseIndices(value);
        });
    decodeObjWithMap<AccessorSparseValues>(
        j, "values", sparse.values, [this](const nlohmann::json &value) {
          return decodeAccessorSparseValues(value);
        });
    return sparse;
  }

  Accessor decodeAccessor(const nlohmann::json &j) {
    Accessor accessor;
    decodeValue(j, "bufferView", accessor.bufferView);
    decodeValue(j, "byteOffset", accessor.byteOffset);
    decodeEnumValue<Accessor::ComponentType>(j, "componentType",
                                             accessor.componentType,
                                             Accessor::ComponentTypeFromInt);
    decodeValue(j, "normalized", accessor.normalized);
    decodeValue(j, "count", accessor.count);
    decodeEnumValue<Accessor::Type>(j, "type", accessor.type,
                                    Accessor::TypeFromString);
    decodeValue(j, "max", accessor.max);
    decodeValue(j, "min", accessor.min);
    decodeObjWithMap<AccessorSparse>(j, "sparse", accessor.sparse,
                                     [this](const nlohmann::json &value) {
                                       return decodeAccessorSparse(value);
                                     });
    decodeValue(j, "name", accessor.name);
    return accessor;
  }

  AnimationChannelTarget decodeAnimationChannelTarget(const nlohmann::json &j) {
    AnimationChannelTarget target;
    decodeValue(j, "node", target.node);
    decodeEnumValue<AnimationChannelTarget::Path>(
        j, "path", target.path, AnimationChannelTarget::PathFromString);
    return target;
  }

  AnimationChannel decodeAnimationChannel(const nlohmann::json &j) {
    AnimationChannel channel;
    decodeValue(j, "sampler", channel.sampler);
    decodeObjWithMap<AnimationChannelTarget>(
        j, "target", channel.target, [this](const nlohmann::json &value) {
          return decodeAnimationChannelTarget(value);
        });
    return channel;
  }

  AnimationSampler decodeAnimationSampler(const nlohmann::json &j) {
    AnimationSampler sampler;
    decodeValue(j, "input", sampler.input);
    decodeEnumValue<AnimationSampler::Interpolation>(
        j, "interpolation", sampler.interpolation,
        AnimationSampler::InterpolationFromString);
    decodeValue(j, "output", sampler.output);
    return sampler;
  }

  Animation decodeAnimation(const nlohmann::json &j) {
    Animation animation;
    decodeValue(j, "name", animation.name);

    decodeArrayWithMapElem<AnimationChannel>(
        j, "channels", animation.channels, [this](const nlohmann::json &value) {
          return decodeAnimationChannel(value);
        });

    decodeArrayWithMapElem<AnimationSampler>(
        j, "samplers", animation.samplers, [this](const nlohmann::json &value) {
          return decodeAnimationSampler(value);
        });

    return animation;
  }

  Asset decodeAsset(const nlohmann::json &j) {
    Asset asset;
    decodeValue(j, "copyright", asset.copyright);
    decodeValue(j, "generator", asset.generator);
    decodeValue(j, "version", asset.version);
    decodeValue(j, "minVersion", asset.minVersion);
    return asset;
  }

  Buffer decodeBuffer(const nlohmann::json &j) {
    Buffer buffer;
    decodeValue(j, "uri", buffer.uri);
    decodeValue(j, "byteLength", buffer.byteLength);
    decodeValue(j, "name", buffer.name);
    return buffer;
  }

  BufferView decodeBufferView(const nlohmann::json &j) {
    BufferView bufferView;
    decodeValue(j, "buffer", bufferView.buffer);
    decodeValue(j, "byteOffset", bufferView.byteOffset);
    decodeValue(j, "byteLength", bufferView.byteLength);
    decodeValue(j, "byteStride", bufferView.byteStride);
    decodeValue(j, "target", bufferView.target);
    decodeValue(j, "name", bufferView.name);
    return bufferView;
  }

  CameraOrthographic decodeCameraOrthographic(const nlohmann::json &j) {
    CameraOrthographic camera;
    decodeValue(j, "xmag", camera.xmag);
    decodeValue(j, "ymag", camera.ymag);
    decodeValue(j, "zfar", camera.zfar);
    decodeValue(j, "znear", camera.znear);
    return camera;
  }

  CameraPerspective decodeCameraPerspective(const nlohmann::json &j) {
    CameraPerspective camera;
    decodeValue(j, "aspectRatio", camera.aspectRatio);
    decodeValue(j, "yfov", camera.yfov);
    decodeValue(j, "zfar", camera.zfar);
    decodeValue(j, "znear", camera.znear);
    return camera;
  }

  Camera decodeCamera(const nlohmann::json &j) {
    Camera camera;
    decodeEnumValue<Camera::Type>(j, "type", camera.type,
                                  Camera::TypeFromString);
    decodeValue(j, "name", camera.name);

    if (camera.type == Camera::Type::PERSPECTIVE) {
      decodeObjWithMap<CameraPerspective>(j, "perspective", camera.perspective,
                                          [this](const nlohmann::json &value) {
                                            return decodeCameraPerspective(
                                                value);
                                          });
    } else if (camera.type == Camera::Type::ORTHOGRAPHIC) {
      decodeObjWithMap<CameraOrthographic>(
          j, "orthographic", camera.orthographic,
          [this](const nlohmann::json &value) {
            return decodeCameraOrthographic(value);
          });
    }

    return camera;
  }

  Image decodeImage(const nlohmann::json &j) {
    Image image;
    decodeValue(j, "uri", image.uri);
    decodeEnumValue<Image::MimeType>(j, "mimeType", image.mimeType,
                                     Image::MimeTypeFromString);
    decodeValue(j, "bufferView", image.bufferView);
    decodeValue(j, "name", image.name);

    return image;
  }

  Texture decodeTexture(const nlohmann::json &j) {
    Texture texture;
    decodeValue(j, "sampler", texture.sampler);
    decodeValue(j, "source", texture.source);
    decodeValue(j, "name", texture.name);
    return texture;
  }

  TextureInfo decodeTextureInfo(const nlohmann::json &j) {
    TextureInfo textureInfo;
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

  MaterialPBRMetallicRoughness
  decodeMaterialPBRMetallicRoughness(const nlohmann::json &j) {
    MaterialPBRMetallicRoughness pbr;
    decodeValueWithMap<std::array<float, 4>>(
        j, "baseColorFactor", pbr.baseColorFactor,
        [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 4>>();
        });
    decodeObjWithMap<TextureInfo>(j, "baseColorTexture", pbr.baseColorTexture,
                                  [this](const nlohmann::json &value) {
                                    return decodeTextureInfo(value);
                                  });
    decodeValue(j, "metallicFactor", pbr.metallicFactor);
    decodeValue(j, "roughnessFactor", pbr.roughnessFactor);
    decodeObjWithMap<TextureInfo>(j, "metallicRoughnessTexture",
                                  pbr.metallicRoughnessTexture,
                                  [this](const nlohmann::json &value) {
                                    return decodeTextureInfo(value);
                                  });
    return pbr;
  }

  MaterialNormalTextureInfo
  decodeMaterialNormalTextureInfo(const nlohmann::json &j) {
    MaterialNormalTextureInfo normal;
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

  MaterialOcclusionTextureInfo
  decodeMaterialOcclusionTextureInfo(const nlohmann::json &j) {
    MaterialOcclusionTextureInfo occlusion;
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

  vrmc::ShadingShiftTexture decodeShadingShiftTexture(const nlohmann::json &j) {
    vrmc::ShadingShiftTexture texture;
    decodeValue(j, "index", texture.index);
    decodeValue(j, "texCoord", texture.texCoord);
    decodeValue(j, "scale", texture.scale);
    return texture;
  }

  vrmc::MaterialsMtoon decodeMaterialsMtoon(const nlohmann::json &j) {
    vrmc::MaterialsMtoon mtoon;
    decodeValue(j, "specVersion", mtoon.specVersion);

    decodeValue(j, "transparentWithZWrite", mtoon.transparentWithZWrite);
    decodeValue(j, "renderQueueOffsetNumber", mtoon.renderQueueOffsetNumber);
    decodeValueWithMap<std::array<float, 3>>(
        j, "shadeColorFactor", mtoon.shadeColorFactor,
        [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 3>>();
        });
    decodeObjWithMap<TextureInfo>(j, "shadeMultiplyTexture",
                                  mtoon.shadeMultiplyTexture,
                                  [this](const nlohmann::json &value) {
                                    return decodeTextureInfo(value);
                                  });
    decodeValue(j, "shadingShiftFactor", mtoon.shadingShiftFactor);
    decodeObjWithMap<vrmc::ShadingShiftTexture>(
        j, "shadingShiftTexture", mtoon.shadingShiftTexture,
        [this](const nlohmann::json &value) {
          return decodeShadingShiftTexture(value);
        });
    decodeValue(j, "shadingToonyFactor", mtoon.shadingToonyFactor);
    decodeValue(j, "giEqualizationFactor", mtoon.giEqualizationFactor);
    decodeValueWithMap<std::array<float, 3>>(
        j, "matcapFactor", mtoon.matcapFactor,
        [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 3>>();
        });
    decodeObjWithMap<TextureInfo>(j, "matcapTexture", mtoon.matcapTexture,
                                  [this](const nlohmann::json &value) {
                                    return decodeTextureInfo(value);
                                  });
    decodeValueWithMap<std::array<float, 3>>(
        j, "parametricRimColorFactor", mtoon.parametricRimColorFactor,
        [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 3>>();
        });
    decodeObjWithMap<TextureInfo>(j, "rimMultiplyTexture",
                                  mtoon.rimMultiplyTexture,
                                  [this](const nlohmann::json &value) {
                                    return decodeTextureInfo(value);
                                  });
    decodeValue(j, "rimLightingMixFactor", mtoon.rimLightingMixFactor);
    decodeValue(j, "parametricRimFresnelPowerFactor",
                mtoon.parametricRimFresnelPowerFactor);
    decodeValue(j, "parametricRimLiftFactor", mtoon.parametricRimLiftFactor);
    decodeEnumValue<vrmc::MaterialsMtoon::OutlineWidthMode>(
        j, "outlineWidthMode", mtoon.outlineWidthMode,
        vrmc::MaterialsMtoon::OutlineWidthModeFromString);
    decodeValue(j, "outlineWidthFactor", mtoon.outlineWidthFactor);
    decodeObjWithMap<TextureInfo>(j, "outlineWidthMultiplyTexture",
                                  mtoon.outlineWidthMultiplyTexture,
                                  [this](const nlohmann::json &value) {
                                    return decodeTextureInfo(value);
                                  });
    decodeValueWithMap<std::array<float, 3>>(
        j, "outlineColorFactor", mtoon.outlineColorFactor,
        [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 3>>();
        });
    decodeValue(j, "outlineLightingMixFactor", mtoon.outlineLightingMixFactor);
    decodeObjWithMap<TextureInfo>(j, "uvAnimationMaskTexture",
                                  mtoon.uvAnimationMaskTexture,
                                  [this](const nlohmann::json &value) {
                                    return decodeTextureInfo(value);
                                  });
    decodeValue(j, "uvAnimationScrollXSpeedFactor",
                mtoon.uvAnimationScrollXSpeedFactor);
    decodeValue(j, "uvAnimationScrollYSpeedFactor",
                mtoon.uvAnimationScrollYSpeedFactor);
    decodeValue(j, "uvAnimationRotationSpeedFactor",
                mtoon.uvAnimationRotationSpeedFactor);

    return mtoon;
  }

  Material decodeMaterial(const nlohmann::json &j) {
    Material material;
    decodeValue(j, "name", material.name);
    decodeObjWithMap<MaterialPBRMetallicRoughness>(
        j, "pbrMetallicRoughness", material.pbrMetallicRoughness,
        [this](const nlohmann::json &value) {
          return decodeMaterialPBRMetallicRoughness(value);
        });
    decodeObjWithMap<MaterialNormalTextureInfo>(
        j, "normalTexture", material.normalTexture,
        [this](const nlohmann::json &value) {
          return decodeMaterialNormalTextureInfo(value);
        });
    decodeObjWithMap<MaterialOcclusionTextureInfo>(
        j, "occlusionTexture", material.occlusionTexture,
        [this](const nlohmann::json &value) {
          return decodeMaterialOcclusionTextureInfo(value);
        });
    decodeObjWithMap<TextureInfo>(j, "emissiveTexture",
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
    decodeEnumValue<Material::AlphaMode>(j, "alphaMode", material.alphaMode,
                                         Material::AlphaModeFromString);
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

      decodeObjWithMap<vrmc::MaterialsMtoon>(
          *extensionsObj, GLTFExtensionVRMCMaterialsMtoon, material.mtoon,
          [this](const nlohmann::json &value) {
            return decodeMaterialsMtoon(value);
          });
    }

    return material;
  }

  void decodeMeshPrimitiveTarget(const nlohmann::json &j,
                                 MeshPrimitiveTarget &target) {
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

  MeshPrimitiveAttributes
  decodeMeshPrimitiveAttributes(const nlohmann::json &j) {
    MeshPrimitiveAttributes attributes;
    decodeMeshPrimitiveTarget(j, attributes);
    attributes.texcoords =
        decodeMeshPrimitiveAttributesSequenceKey(j, "TEXCOORD");
    attributes.colors = decodeMeshPrimitiveAttributesSequenceKey(j, "COLOR");
    attributes.joints = decodeMeshPrimitiveAttributesSequenceKey(j, "JOINTS");
    attributes.weights = decodeMeshPrimitiveAttributesSequenceKey(j, "WEIGHTS");
    return attributes;
  }

  MeshPrimitive decodeMeshPrimitive(const nlohmann::json &j) {
    MeshPrimitive primitive;
    decodeObjWithMap<MeshPrimitiveAttributes>(
        j, "attributes", primitive.attributes,
        [this](const nlohmann::json &value) {
          return decodeMeshPrimitiveAttributes(value);
        });
    decodeValue(j, "indices", primitive.indices);
    decodeValue(j, "material", primitive.material);
    decodeEnumValue<MeshPrimitive::Mode>(j, "mode", primitive.mode,
                                         MeshPrimitive::ModeFromInt);

    decodeArrayWithMapElem<MeshPrimitiveTarget>(
        j, "targets", primitive.targets, [this](const nlohmann::json &value) {
          MeshPrimitiveTarget target;
          decodeMeshPrimitiveTarget(value, target);
          return target;
        });

    auto extensionsObj = decodeOptionalObj(j, "extensions");
    if (extensionsObj) {
      decodeObjWithMap<MeshPrimitiveDracoExtension>(
          *extensionsObj, GLTFExtensionKHRDracoMeshCompression,
          primitive.dracoExtension, [this](const nlohmann::json &value) {
            return decodeMeshPrimitiveDracoExtension(value);
          });
    }

    return primitive;
  }

  Mesh decodeMesh(const nlohmann::json &j) {
    Mesh mesh;
    decodeArrayWithMapElem<MeshPrimitive>(j, "primitives", mesh.primitives,
                                          [this](const nlohmann::json &value) {
                                            return decodeMeshPrimitive(value);
                                          });
    decodeValue(j, "name", mesh.name);
    decodeValue(j, "weights", mesh.weights);
    return mesh;
  }

  Node decodeNode(const nlohmann::json &j) {
    Node node;

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

  Sampler decodeSampler(const nlohmann::json &j) {
    Sampler sampler;

    decodeEnumValue<Sampler::MagFilter>(j, "magFilter", sampler.magFilter,
                                        Sampler::MagFilterFromInt);

    decodeEnumValue<Sampler::MinFilter>(j, "minFilter", sampler.minFilter,
                                        Sampler::MinFilterFromInt);

    decodeEnumValue<Sampler::WrapMode>(j, "wrapS", sampler.wrapS,
                                       Sampler::WrapModeFromInt);

    decodeEnumValue<Sampler::WrapMode>(j, "wrapT", sampler.wrapT,
                                       Sampler::WrapModeFromInt);

    decodeValue(j, "name", sampler.name);

    return sampler;
  }

  Scene decodeScene(const nlohmann::json &j) {
    Scene scene;
    decodeValue(j, "nodes", scene.nodes);
    decodeValue(j, "name", scene.name);
    return scene;
  }

  Skin decodeSkin(const nlohmann::json &j) {
    Skin skin;
    decodeValue(j, "inverseBindMatrices", skin.inverseBindMatrices);
    decodeValue(j, "skeleton", skin.skeleton);
    decodeValue(j, "joints", skin.joints);
    decodeValue(j, "name", skin.name);
    return skin;
  }

  Json decodeJson(const nlohmann::json &j) {
    pushStack("root");

    Json data;

    decodeValue(j, "extensionsUsed", data.extensionsUsed);
    decodeValue(j, "extensionsRequired", data.extensionsRequired);

    decodeArrayWithMapElem<Accessor>(
        j, "accessors", data.accessors,
        [this](const nlohmann::json &item) { return decodeAccessor(item); });
    decodeArrayWithMapElem<Animation>(
        j, "animations", data.animations,
        [this](const nlohmann::json &item) { return decodeAnimation(item); });

    decodeObjWithMap<Asset>(
        j, "asset", data.asset,
        [this](const nlohmann::json &obj) { return decodeAsset(obj); });

    decodeArrayWithMapElem<Buffer>(
        j, "buffers", data.buffers,
        [this](const nlohmann::json &item) { return decodeBuffer(item); });
    decodeArrayWithMapElem<BufferView>(
        j, "bufferViews", data.bufferViews,
        [this](const nlohmann::json &item) { return decodeBufferView(item); });
    decodeArrayWithMapElem<Camera>(
        j, "cameras", data.cameras,
        [this](const nlohmann::json &item) { return decodeCamera(item); });
    decodeArrayWithMapElem<Image>(
        j, "images", data.images,
        [this](const nlohmann::json &item) { return decodeImage(item); });
    decodeArrayWithMapElem<Material>(
        j, "materials", data.materials,
        [this](const nlohmann::json &item) { return decodeMaterial(item); });
    decodeArrayWithMapElem<Mesh>(
        j, "meshes", data.meshes,
        [this](const nlohmann::json &item) { return decodeMesh(item); });
    decodeArrayWithMapElem<Node>(
        j, "nodes", data.nodes,
        [this](const nlohmann::json &item) { return decodeNode(item); });
    decodeArrayWithMapElem<Sampler>(
        j, "samplers", data.samplers,
        [this](const nlohmann::json &item) { return decodeSampler(item); });

    decodeValue(j, "scene", data.scene);

    decodeArrayWithMapElem<Scene>(
        j, "scenes", data.scenes,
        [this](const nlohmann::json &item) { return decodeScene(item); });
    decodeArrayWithMapElem<Skin>(
        j, "skins", data.skins,
        [this](const nlohmann::json &item) { return decodeSkin(item); });
    decodeArrayWithMapElem<Texture>(
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

      decodeObjWithMap<vrm0::VRM>(
          *extensionsObj, GLTFExtensionVRM, data.vrm0,
          [this](const nlohmann::json &item) { return decodeVRM0VRM(item); });

      decodeObjWithMap<vrmc::VRM>(
          *extensionsObj, GLTFExtensionVRMCvrm, data.vrm1,
          [this](const nlohmann::json &item) { return decodeVRM1VRM(item); });

      decodeObjWithMap<vrmc::SpringBone>(
          *extensionsObj, GLTFExtensionVRMCSpringBone, data.springBone,
          [this](const nlohmann::json &item) {
            return decodeVRM1SpringBone(item);
          });
    }

    popStack();

    return data;
  }

#pragma mark - draco
  MeshPrimitiveDracoExtension
  decodeMeshPrimitiveDracoExtension(const nlohmann::json &j) {
    MeshPrimitiveDracoExtension dracoExtension;
    decodeValue(j, "bufferView", dracoExtension.bufferView);
    decodeObjWithMap<MeshPrimitiveAttributes>(
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
    decodeObjWithMap<TextureInfo>(j, "anisotropyTexture",
                                  anisotropy.anisotropyTexture,
                                  [this](const nlohmann::json &value) {
                                    return decodeTextureInfo(value);
                                  });
    return anisotropy;
  }

  KHRMaterialClearcoat decodeKHRMaterialClearcoat(const nlohmann::json &j) {
    KHRMaterialClearcoat clearcoat;
    decodeValue(j, "clearcoatFactor", clearcoat.clearcoatFactor);
    decodeObjWithMap<TextureInfo>(j, "clearcoatTexture",
                                  clearcoat.clearcoatTexture,
                                  [this](const nlohmann::json &value) {
                                    return decodeTextureInfo(value);
                                  });
    decodeValue(j, "clearcoatRoughnessFactor",
                clearcoat.clearcoatRoughnessFactor);
    decodeObjWithMap<TextureInfo>(j, "clearcoatRoughnessTexture",
                                  clearcoat.clearcoatRoughnessTexture,
                                  [this](const nlohmann::json &value) {
                                    return decodeTextureInfo(value);
                                  });
    decodeObjWithMap<MaterialNormalTextureInfo>(
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
    decodeObjWithMap<TextureInfo>(j, "iridescenceTexture",
                                  iridescence.iridescenceTexture,
                                  [this](const nlohmann::json &value) {
                                    return decodeTextureInfo(value);
                                  });
    decodeValue(j, "iridescenceIor", iridescence.iridescenceIor);
    decodeValue(j, "iridescenceThicknessMinimum",
                iridescence.iridescenceThicknessMinimum);
    decodeValue(j, "iridescenceThicknessMaximum",
                iridescence.iridescenceThicknessMaximum);
    decodeObjWithMap<TextureInfo>(j, "iridescenceThicknessTexture",
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
    decodeObjWithMap<TextureInfo>(j, "sheenColorTexture",
                                  sheen.sheenColorTexture,
                                  [this](const nlohmann::json &value) {
                                    return decodeTextureInfo(value);
                                  });
    decodeValue(j, "sheenRoughnessFactor", sheen.sheenRoughnessFactor);
    decodeObjWithMap<TextureInfo>(j, "sheenRoughnessTexture",
                                  sheen.sheenRoughnessTexture,
                                  [this](const nlohmann::json &value) {
                                    return decodeTextureInfo(value);
                                  });
    return sheen;
  }

  KHRMaterialSpecular decodeKHRMaterialSpecular(const nlohmann::json &j) {
    KHRMaterialSpecular specular;
    decodeValue(j, "specularFactor", specular.specularFactor);
    decodeObjWithMap<TextureInfo>(j, "specularTexture",
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
    decodeObjWithMap<TextureInfo>(j, "specularColorTexture",
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
    decodeObjWithMap<TextureInfo>(j, "transmissionTexture",
                                  transmission.transmissionTexture,
                                  [this](const nlohmann::json &value) {
                                    return decodeTextureInfo(value);
                                  });
    return transmission;
  }

  KHRMaterialVolume decodeKHRMaterialVolume(const nlohmann::json &j) {
    KHRMaterialVolume volume;
    decodeValue(j, "thicknessFactor", volume.thicknessFactor);
    decodeObjWithMap<TextureInfo>(j, "thicknessTexture",
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

  vrmc::Meta decodeVRM1Meta(const nlohmann::json &j) {
    vrmc::Meta meta;
    decodeValue(j, "name", meta.name);
    decodeValue(j, "version", meta.version);
    decodeValue(j, "authors", meta.authors);
    decodeValue(j, "copyrightInformation", meta.copyrightInformation);
    decodeValue(j, "contactInformation", meta.contactInformation);
    decodeValue(j, "references", meta.references);
    decodeValue(j, "thirdPartyLicenses", meta.thirdPartyLicenses);
    decodeValue(j, "thumbnailImage", meta.thumbnailImage);
    decodeValue(j, "licenseUrl", meta.licenseUrl);
    decodeEnumValue<vrmc::Meta::AvatarPermission>(
        j, "avatarPermission", meta.avatarPermission,
        vrmc::Meta::AvatarPermissionFromString);
    decodeValue(j, "allowExcessivelyViolentUsage",
                meta.allowExcessivelyViolentUsage);
    decodeValue(j, "allowExcessivelySexualUsage",
                meta.allowExcessivelySexualUsage);
    decodeEnumValue<vrmc::Meta::CommercialUsage>(
        j, "commercialUsage", meta.commercialUsage,
        vrmc::Meta::CommercialUsageFromString);
    decodeValue(j, "allowPoliticalOrReligiousUsage",
                meta.allowPoliticalOrReligiousUsage);
    decodeValue(j, "allowAntisocialOrHateUsage",
                meta.allowAntisocialOrHateUsage);
    decodeEnumValue<vrmc::Meta::CreditNotation>(
        j, "creditNotation", meta.creditNotation,
        vrmc::Meta::CreditNotationFromString);
    decodeValue(j, "allowRedistribution", meta.allowRedistribution);
    decodeEnumValue<vrmc::Meta::Modification>(
        j, "modification", meta.modification,
        vrmc::Meta::ModificationFromString);
    decodeValue(j, "otherLicenseUrl", meta.otherLicenseUrl);
    return meta;
  }

  vrmc::HumanoidHumanBone decodeVRM1HumanoidHumanBone(const nlohmann::json &j) {
    vrmc::HumanoidHumanBone bone;
    decodeValue(j, "node", bone.node);
    return bone;
  }

  vrmc::HumanoidHumanBones
  decodeVRM1HumanoidHumanBones(const nlohmann::json &j) {
    vrmc::HumanoidHumanBones bones;
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "hips", bones.hips, [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "spine", bones.spine, [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "chest", bones.chest, [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "upperChest", bones.upperChest, [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "neck", bones.neck, [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "head", bones.head, [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftEye", bones.leftEye, [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightEye", bones.rightEye, [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "jaw", bones.jaw, [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftUpperLeg", bones.leftUpperLeg,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftLowerLeg", bones.leftLowerLeg,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftFoot", bones.leftFoot, [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftToes", bones.leftToes, [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightUpperLeg", bones.rightUpperLeg,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightLowerLeg", bones.rightLowerLeg,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightFoot", bones.rightFoot, [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightToes", bones.rightToes, [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftShoulder", bones.leftShoulder,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftUpperArm", bones.leftUpperArm,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftLowerArm", bones.leftLowerArm,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftHand", bones.leftHand, [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightShoulder", bones.rightShoulder,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightUpperArm", bones.rightUpperArm,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightLowerArm", bones.rightLowerArm,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightHand", bones.rightHand, [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftThumbMetacarpal", bones.leftThumbMetacarpal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftThumbProximal", bones.leftThumbProximal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftThumbDistal", bones.leftThumbDistal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftIndexProximal", bones.leftIndexProximal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftIndexIntermediate", bones.leftIndexIntermediate,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftIndexDistal", bones.leftIndexDistal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftMiddleProximal", bones.leftMiddleProximal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftMiddleIntermediate", bones.leftMiddleIntermediate,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftMiddleDistal", bones.leftMiddleDistal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftRingProximal", bones.leftRingProximal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftRingIntermediate", bones.leftRingIntermediate,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftRingDistal", bones.leftRingDistal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftLittleProximal", bones.leftLittleProximal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftLittleIntermediate", bones.leftLittleIntermediate,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "leftLittleDistal", bones.leftLittleDistal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightThumbMetacarpal", bones.rightThumbMetacarpal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightThumbProximal", bones.rightThumbProximal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightThumbDistal", bones.rightThumbDistal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightIndexProximal", bones.rightIndexProximal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightIndexIntermediate", bones.rightIndexIntermediate,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightIndexDistal", bones.rightIndexDistal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightMiddleProximal", bones.rightMiddleProximal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightMiddleIntermediate", bones.rightMiddleIntermediate,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightMiddleDistal", bones.rightMiddleDistal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightRingProximal", bones.rightRingProximal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightRingIntermediate", bones.rightRingIntermediate,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightRingDistal", bones.rightRingDistal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightLittleProximal", bones.rightLittleProximal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightLittleIntermediate", bones.rightLittleIntermediate,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    decodeObjWithMap<vrmc::HumanoidHumanBone>(
        j, "rightLittleDistal", bones.rightLittleDistal,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBone(value);
        });
    return bones;
  }

  vrmc::Humanoid decodeVRM1Humanoid(const nlohmann::json &j) {
    vrmc::Humanoid humanoid;
    decodeObjWithMap<vrmc::HumanoidHumanBones>(
        j, "humanBones", humanoid.humanBones,
        [this](const nlohmann::json &value) {
          return decodeVRM1HumanoidHumanBones(value);
        });
    return humanoid;
  }

  vrmc::FirstPersonMeshAnnotation
  decodeVRM1FirstPersonMeshAnnotation(const nlohmann::json &j) {
    vrmc::FirstPersonMeshAnnotation annotation;
    decodeValue(j, "node", annotation.node);
    decodeEnumValue<vrmc::FirstPersonMeshAnnotation::Type>(
        j, "type", annotation.type,
        vrmc::FirstPersonMeshAnnotation::TypeFromString);
    return annotation;
  }

  vrmc::FirstPerson decodeVRM1FirstPerson(const nlohmann::json &j) {
    vrmc::FirstPerson firstPerson;
    decodeArrayWithMapElem<vrmc::FirstPersonMeshAnnotation>(
        j, "meshAnnotations", firstPerson.meshAnnotations,
        [this](const nlohmann::json &item) {
          return decodeVRM1FirstPersonMeshAnnotation(item);
        });
    return firstPerson;
  }

  vrmc::LookAtRangeMap decodeVRM1LookAtRangeMap(const nlohmann::json &j) {
    vrmc::LookAtRangeMap rangeMap;
    decodeValue(j, "inputMaxValue", rangeMap.inputMaxValue);
    decodeValue(j, "outputScale", rangeMap.outputScale);
    return rangeMap;
  }

  vrmc::LookAt decodeVRM1LookAt(const nlohmann::json &j) {
    vrmc::LookAt lookAt;
    decodeValueWithMap<std::array<float, 3>>(
        j, "offsetFromHeadBone", lookAt.offsetFromHeadBone,
        [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 3>>();
        });
    decodeEnumValue<vrmc::LookAt::Type>(j, "type", lookAt.type,
                                        vrmc::LookAt::TypeFromString);

    decodeObjWithMap<vrmc::LookAtRangeMap>(
        j, "rangeMapHorizontalInner", lookAt.rangeMapHorizontalInner,
        [this](const nlohmann::json &value) {
          return decodeVRM1LookAtRangeMap(value);
        });
    decodeObjWithMap<vrmc::LookAtRangeMap>(
        j, "rangeMapHorizontalOuter", lookAt.rangeMapHorizontalOuter,
        [this](const nlohmann::json &value) {
          return decodeVRM1LookAtRangeMap(value);
        });
    decodeObjWithMap<vrmc::LookAtRangeMap>(
        j, "rangeMapVerticalDown", lookAt.rangeMapVerticalDown,
        [this](const nlohmann::json &value) {
          return decodeVRM1LookAtRangeMap(value);
        });
    decodeObjWithMap<vrmc::LookAtRangeMap>(
        j, "rangeMapVerticalUp", lookAt.rangeMapVerticalUp,
        [this](const nlohmann::json &value) {
          return decodeVRM1LookAtRangeMap(value);
        });
    return lookAt;
  }

  vrmc::ExpressionMaterialColorBind
  decodeVRM1ExpressionMaterialColorBind(const nlohmann::json &j) {
    vrmc::ExpressionMaterialColorBind bind;
    decodeValue(j, "material", bind.material);
    decodeEnumValue<vrmc::ExpressionMaterialColorBind::Type>(
        j, "type", bind.type,
        vrmc::ExpressionMaterialColorBind::TypeFromString);
    decodeValueWithMap<std::array<float, 4>>(
        j, "targetValue", bind.targetValue,
        [this](const nlohmann::json &value) {
          if (!value.is_array() || value.size() != 4)
            throw InvalidFormatException(context());
          return value.get<std::array<float, 4>>();
        });
    return bind;
  }

  vrmc::ExpressionMorphTargetBind
  decodeVRM1ExpressionMorphTargetBind(const nlohmann::json &j) {
    vrmc::ExpressionMorphTargetBind bind;
    decodeValue(j, "node", bind.node);
    decodeValue(j, "index", bind.index);
    decodeValue(j, "weight", bind.weight);
    return bind;
  }

  vrmc::ExpressionTextureTransformBind
  decodeVRM1ExpressionTextureTransformBind(const nlohmann::json &j) {
    vrmc::ExpressionTextureTransformBind bind;
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

  vrmc::Expression decodeVRM1Expression(const nlohmann::json &j) {
    vrmc::Expression expression;

    decodeArrayWithMapElem<vrmc::ExpressionMorphTargetBind>(
        j, "morphTargetBinds", expression.morphTargetBinds,
        [this](const nlohmann::json &item) {
          return decodeVRM1ExpressionMorphTargetBind(item);
        });

    decodeArrayWithMapElem<vrmc::ExpressionMaterialColorBind>(
        j, "materialColorBinds", expression.materialColorBinds,
        [this](const nlohmann::json &item) {
          return decodeVRM1ExpressionMaterialColorBind(item);
        });

    decodeArrayWithMapElem<vrmc::ExpressionTextureTransformBind>(
        j, "textureTransformBinds", expression.textureTransformBinds,
        [this](const nlohmann::json &item) {
          return decodeVRM1ExpressionTextureTransformBind(item);
        });

    decodeValue(j, "isBinary", expression.isBinary);
    decodeEnumValue<vrmc::Expression::Override>(
        j, "overrideBlink", expression.overrideBlink,
        vrmc::Expression::OverrideFromString);
    decodeEnumValue<vrmc::Expression::Override>(
        j, "overrideLookAt", expression.overrideLookAt,
        vrmc::Expression::OverrideFromString);
    decodeEnumValue<vrmc::Expression::Override>(
        j, "overrideMouth", expression.overrideMouth,
        vrmc::Expression::OverrideFromString);

    return expression;
  }

  vrmc::ExpressionsPreset decodeVRM1ExpressionsPreset(const nlohmann::json &j) {
    vrmc::ExpressionsPreset preset;
    decodeObjWithMap<vrmc::Expression>(j, "happy", preset.happy,
                                       [this](const nlohmann::json &value) {
                                         return decodeVRM1Expression(value);
                                       });
    decodeObjWithMap<vrmc::Expression>(j, "angry", preset.angry,
                                       [this](const nlohmann::json &value) {
                                         return decodeVRM1Expression(value);
                                       });
    decodeObjWithMap<vrmc::Expression>(j, "sad", preset.sad,
                                       [this](const nlohmann::json &value) {
                                         return decodeVRM1Expression(value);
                                       });
    decodeObjWithMap<vrmc::Expression>(j, "relaxed", preset.relaxed,
                                       [this](const nlohmann::json &value) {
                                         return decodeVRM1Expression(value);
                                       });
    decodeObjWithMap<vrmc::Expression>(j, "surprised", preset.surprised,
                                       [this](const nlohmann::json &value) {
                                         return decodeVRM1Expression(value);
                                       });
    decodeObjWithMap<vrmc::Expression>(j, "aa", preset.aa,
                                       [this](const nlohmann::json &value) {
                                         return decodeVRM1Expression(value);
                                       });
    decodeObjWithMap<vrmc::Expression>(j, "ih", preset.ih,
                                       [this](const nlohmann::json &value) {
                                         return decodeVRM1Expression(value);
                                       });
    decodeObjWithMap<vrmc::Expression>(j, "ou", preset.ou,
                                       [this](const nlohmann::json &value) {
                                         return decodeVRM1Expression(value);
                                       });
    decodeObjWithMap<vrmc::Expression>(j, "ee", preset.ee,
                                       [this](const nlohmann::json &value) {
                                         return decodeVRM1Expression(value);
                                       });
    decodeObjWithMap<vrmc::Expression>(j, "oh", preset.oh,
                                       [this](const nlohmann::json &value) {
                                         return decodeVRM1Expression(value);
                                       });
    decodeObjWithMap<vrmc::Expression>(j, "blink", preset.blink,
                                       [this](const nlohmann::json &value) {
                                         return decodeVRM1Expression(value);
                                       });
    decodeObjWithMap<vrmc::Expression>(j, "blinkLeft", preset.blinkLeft,
                                       [this](const nlohmann::json &value) {
                                         return decodeVRM1Expression(value);
                                       });
    decodeObjWithMap<vrmc::Expression>(j, "blinkRight", preset.blinkRight,
                                       [this](const nlohmann::json &value) {
                                         return decodeVRM1Expression(value);
                                       });
    decodeObjWithMap<vrmc::Expression>(j, "lookUp", preset.lookUp,
                                       [this](const nlohmann::json &value) {
                                         return decodeVRM1Expression(value);
                                       });
    decodeObjWithMap<vrmc::Expression>(j, "lookDown", preset.lookDown,
                                       [this](const nlohmann::json &value) {
                                         return decodeVRM1Expression(value);
                                       });
    decodeObjWithMap<vrmc::Expression>(j, "lookLeft", preset.lookLeft,
                                       [this](const nlohmann::json &value) {
                                         return decodeVRM1Expression(value);
                                       });
    decodeObjWithMap<vrmc::Expression>(j, "lookRight", preset.lookRight,
                                       [this](const nlohmann::json &value) {
                                         return decodeVRM1Expression(value);
                                       });
    decodeObjWithMap<vrmc::Expression>(j, "neutral", preset.neutral,
                                       [this](const nlohmann::json &value) {
                                         return decodeVRM1Expression(value);
                                       });
    return preset;
  }

  vrmc::Expressions decodeVRM1Expressions(const nlohmann::json &j) {
    vrmc::Expressions expressions;
    decodeObjWithMap<vrmc::ExpressionsPreset>(
        j, "preset", expressions.preset, [this](const nlohmann::json &value) {
          return decodeVRM1ExpressionsPreset(value);
        });
    auto customObj = decodeOptionalObj(j, "custom");
    if (customObj) {
      std::map<std::string, vrmc::Expression> custom;
      for (const auto &item : customObj->items()) {
        custom[item.key()] = decodeVRM1Expression(item.value());
      }
      expressions.custom = custom;
    }
    return expressions;
  }

  vrmc::VRM decodeVRM1VRM(const nlohmann::json &j) {
    vrmc::VRM vrm;
    decodeValue(j, "specVersion", vrm.specVersion);
    decodeObjWithMap<vrmc::Meta>(
        j, "meta", vrm.meta,
        [this](const nlohmann::json &value) { return decodeVRM1Meta(value); });
    decodeObjWithMap<vrmc::Humanoid>(j, "humanoid", vrm.humanoid,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRM1Humanoid(value);
                                     });
    decodeObjWithMap<vrmc::FirstPerson>(j, "firstPerson", vrm.firstPerson,
                                        [this](const nlohmann::json &value) {
                                          return decodeVRM1FirstPerson(value);
                                        });
    decodeObjWithMap<vrmc::LookAt>(j, "lookAt", vrm.lookAt,
                                   [this](const nlohmann::json &value) {
                                     return decodeVRM1LookAt(value);
                                   });
    decodeObjWithMap<vrmc::Expressions>(j, "expressions", vrm.expressions,
                                        [this](const nlohmann::json &value) {
                                          return decodeVRM1Expressions(value);
                                        });

    return vrm;
  }

#pragma mark - VRM 0

  vrm0::VRM decodeVRM0VRM(const nlohmann::json &j) {
    vrm0::VRM vrm;
    decodeValue(j, "exporterVersion", vrm.exporterVersion);
    decodeValue(j, "specVersion", vrm.specVersion);
    decodeObjWithMap<vrm0::Meta>(
        j, "meta", vrm.meta,
        [this](const nlohmann::json &value) { return decodeVRM0Meta(value); });
    decodeObjWithMap<vrm0::Humanoid>(j, "humanoid", vrm.humanoid,
                                     [this](const nlohmann::json &value) {
                                       return decodeVRM0Humanoid(value);
                                     });
    decodeObjWithMap<vrm0::FirstPerson>(j, "firstPerson", vrm.firstPerson,
                                        [this](const nlohmann::json &value) {
                                          return decodeVRM0FirstPerson(value);
                                        });
    decodeObjWithMap<vrm0::BlendShape>(j, "blendShapeMaster",
                                       vrm.blendShapeMaster,
                                       [this](const nlohmann::json &value) {
                                         return decodeVRM0BlendShape(value);
                                       });
    decodeObjWithMap<vrm0::SecondaryAnimation>(
        j, "secondaryAnimation", vrm.secondaryAnimation,
        [this](const nlohmann::json &value) {
          return decodeVRM0SecondaryAnimation(value);
        });
    decodeArrayWithMapElem<vrm0::Material>(j, "materialProperties",
                                           vrm.materialProperties,
                                           [this](const nlohmann::json &item) {
                                             return decodeVRM0Material(item);
                                           });
    return vrm;
  }

  vrm0::Meta decodeVRM0Meta(const nlohmann::json &j) {
    vrm0::Meta meta;
    decodeValue(j, "title", meta.title);
    decodeValue(j, "version", meta.version);
    decodeValue(j, "author", meta.author);
    decodeValue(j, "contactInformation", meta.contactInformation);
    decodeValue(j, "reference", meta.reference);
    decodeValue(j, "texture", meta.texture);
    decodeEnumValue<vrm0::Meta::AllowedUserName>(
        j, "allowedUserName", meta.allowedUserName,
        vrm0::Meta::AllowedUserNameFromString);
    decodeEnumValue<vrm0::Meta::UsagePermission>(
        j, "violentUssageName", meta.violentUsage,
        vrm0::Meta::UsagePermissionFromString);
    decodeEnumValue<vrm0::Meta::UsagePermission>(
        j, "sexualUssageName", meta.sexualUsage,
        vrm0::Meta::UsagePermissionFromString);
    decodeEnumValue<vrm0::Meta::UsagePermission>(
        j, "commercialUssageName", meta.commercialUsage,
        vrm0::Meta::UsagePermissionFromString);
    decodeValue(j, "otherPermissionUrl", meta.otherPermissionUrl);
    decodeEnumValue<vrm0::Meta::LicenseName>(j, "licenseName", meta.licenseName,
                                             vrm0::Meta::LicenseNameFromString);
    decodeValue(j, "otherLicenseUrl", meta.otherLicenseUrl);
    return meta;
  }

  vrm0::Humanoid decodeVRM0Humanoid(const nlohmann::json &j) {
    vrm0::Humanoid humanoid;
    decodeArrayWithMapElem<vrm0::HumanoidBone>(
        j, "humanBones", humanoid.humanBones,
        [this](const nlohmann::json &item) {
          return decodeVRM0HumanoidBone(item);
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

  vrm0::HumanoidBone decodeVRM0HumanoidBone(const nlohmann::json &j) {
    vrm0::HumanoidBone bone;
    decodeEnumValue<vrm0::HumanoidBone::BoneName>(
        j, "bone", bone.bone, vrm0::HumanoidBone::BoneNameFromString);
    decodeValue(j, "node", bone.node);
    decodeValue(j, "useDefaultValues", bone.useDefaultValues);
    decodeObjWithMap<vrm0::Vec3>(
        j, "min", bone.min,
        [this](const nlohmann::json &item) { return decodeVRM0Vec3(item); });
    decodeObjWithMap<vrm0::Vec3>(
        j, "max", bone.max,
        [this](const nlohmann::json &item) { return decodeVRM0Vec3(item); });
    decodeObjWithMap<vrm0::Vec3>(
        j, "center", bone.center,
        [this](const nlohmann::json &item) { return decodeVRM0Vec3(item); });
    decodeValue(j, "axisLength", bone.axisLength);
    return bone;
  }

  vrm0::Vec3 decodeVRM0Vec3(const nlohmann::json &j) {
    vrm0::Vec3 vec;
    decodeValue(j, "x", vec.x);
    decodeValue(j, "y", vec.y);
    decodeValue(j, "z", vec.z);
    return vec;
  }

  vrm0::FirstPersonMeshAnnotation
  decodeVRM0FirstPersonMeshAnnotation(const nlohmann::json &j) {
    vrm0::FirstPersonMeshAnnotation annotation;
    decodeValue(j, "mesh", annotation.mesh);
    decodeValue(j, "firstPersonFlag", annotation.firstPersonFlag);
    return annotation;
  }

  vrm0::FirstPersonDegreeMap
  decodeVRM0FirstPersonDegreeMap(const nlohmann::json &j) {
    vrm0::FirstPersonDegreeMap degreeMap;
    const auto curveArray = decodeOptionalArray(j, "curve");
    if (curveArray) {
      std::vector<vrm0::FirstPersonDegreeMapCurve> curve;
      for (int i = 0; i < curveArray->size() / 4; i++) {
        vrm0::FirstPersonDegreeMapCurve mapping;
        mapping.time = curveArray->at(i * 4 + 0);
        mapping.value = curveArray->at(i * 4 + 1);
        mapping.inTangent = curveArray->at(i * 4 + 2);
        mapping.outTangent = curveArray->at(i * 4 + 3);
        curve.push_back(mapping);
      }
      degreeMap.curve = curve;
    }
    decodeValue(j, "xRange", degreeMap.xRange);
    decodeValue(j, "yRange", degreeMap.yRange);
    return degreeMap;
  }

  vrm0::FirstPerson decodeVRM0FirstPerson(const nlohmann::json &j) {
    vrm0::FirstPerson firstPerson;
    decodeValue(j, "firstPersonBone", firstPerson.firstPersonBone);
    decodeObjWithMap<vrm0::Vec3>(
        j, "firstPersonBoneOffset", firstPerson.firstPersonBoneOffset,
        [this](const nlohmann::json &item) { return decodeVRM0Vec3(item); });
    decodeArrayWithMapElem<vrm0::FirstPersonMeshAnnotation>(
        j, "meshAnnotations", firstPerson.meshAnnotations,
        [this](const nlohmann::json &item) {
          return decodeVRM0FirstPersonMeshAnnotation(item);
        });
    decodeEnumValue<vrm0::FirstPerson::LookAtType>(
        j, "lookAtTypeName", firstPerson.lookAtTypeName,
        vrm0::FirstPerson::LookAtTypeFromString);
    decodeObjWithMap<vrm0::FirstPersonDegreeMap>(
        j, "lookAtHorizontalInner", firstPerson.lookAtHorizontalInner,
        [this](const nlohmann::json &item) {
          return decodeVRM0FirstPersonDegreeMap(item);
        });
    decodeObjWithMap<vrm0::FirstPersonDegreeMap>(
        j, "lookAtHorizontalOuter", firstPerson.lookAtHorizontalOuter,
        [this](const nlohmann::json &item) {
          return decodeVRM0FirstPersonDegreeMap(item);
        });
    decodeObjWithMap<vrm0::FirstPersonDegreeMap>(
        j, "lookAtVerticalDown", firstPerson.lookAtVerticalDown,
        [this](const nlohmann::json &item) {
          return decodeVRM0FirstPersonDegreeMap(item);
        });
    decodeObjWithMap<vrm0::FirstPersonDegreeMap>(
        j, "lookAtVerticalUp", firstPerson.lookAtVerticalUp,
        [this](const nlohmann::json &item) {
          return decodeVRM0FirstPersonDegreeMap(item);
        });
    return firstPerson;
  }

  vrm0::BlendShapeMaterialBind
  decodeVRM0BlendShapeMaterialBind(const nlohmann::json &j) {
    vrm0::BlendShapeMaterialBind materialBind;
    decodeValue(j, "materialName", materialBind.materialName);
    decodeValue(j, "propertyName", materialBind.propertyName);
    decodeValue(j, "targetValue", materialBind.targetValue);
    return materialBind;
  }

  vrm0::BlendShape decodeVRM0BlendShape(const nlohmann::json &j) {
    vrm0::BlendShape blendShape;
    decodeArrayWithMapElem<vrm0::BlendShapeGroup>(
        j, "blendShapeGroups", blendShape.blendShapeGroups,
        [this](const nlohmann::json &item) {
          return decodeVRM0BlendShapeGroup(item);
        });
    return blendShape;
  }

  vrm0::BlendShapeBind decodeVRM0BlendShapeBind(const nlohmann::json &j) {
    vrm0::BlendShapeBind bind;
    decodeValue(j, "mesh", bind.mesh);
    decodeValue(j, "index", bind.index);
    decodeValue(j, "weight", bind.weight);
    return bind;
  }

  vrm0::BlendShapeGroup decodeVRM0BlendShapeGroup(const nlohmann::json &j) {
    vrm0::BlendShapeGroup blendShapeGroup;
    decodeValue(j, "name", blendShapeGroup.name);
    decodeEnumValue<vrm0::BlendShapeGroup::PresetName>(
        j, "presetName", blendShapeGroup.presetName,
        vrm0::BlendShapeGroup::PresetNameFromString);
    decodeArrayWithMapElem<vrm0::BlendShapeBind>(
        j, "binds", blendShapeGroup.binds, [this](const nlohmann::json &item) {
          return decodeVRM0BlendShapeBind(item);
        });
    decodeArrayWithMapElem<vrm0::BlendShapeMaterialBind>(
        j, "materialValues", blendShapeGroup.materialValues,
        [this](const nlohmann::json &item) {
          return decodeVRM0BlendShapeMaterialBind(item);
        });
    decodeValue(j, "isBinary", blendShapeGroup.isBinary);
    return blendShapeGroup;
  }

  vrm0::SecondaryAnimationCollider
  decodeVRM0SecondaryAnimationCollider(const nlohmann::json &j) {
    vrm0::SecondaryAnimationCollider collider;
    decodeObjWithMap<vrm0::Vec3>(
        j, "offset", collider.offset,
        [this](const nlohmann::json &item) { return decodeVRM0Vec3(item); });
    decodeValue(j, "radius", collider.radius);
    return collider;
  }

  vrm0::SecondaryAnimationColliderGroup
  decodeVRM0SecondaryAnimationColliderGroup(const nlohmann::json &j) {
    vrm0::SecondaryAnimationColliderGroup colliderGroup;
    decodeValue(j, "node", colliderGroup.node);
    decodeArrayWithMapElem<vrm0::SecondaryAnimationCollider>(
        j, "colliders", colliderGroup.colliders,
        [this](const nlohmann::json &item) {
          return decodeVRM0SecondaryAnimationCollider(item);
        });
    return colliderGroup;
  }

  vrm0::SecondaryAnimationSpring
  decodeVRM0SecondaryAnimationSpring(const nlohmann::json &j) {
    vrm0::SecondaryAnimationSpring spring;
    decodeValue(j, "comment", spring.comment);
    decodeValue(j, "stiffiness", spring.stiffiness);
    decodeValue(j, "gravityPower", spring.gravityPower);
    decodeObjWithMap<vrm0::Vec3>(
        j, "gravityDir", spring.gravityDir,
        [this](const nlohmann::json &item) { return decodeVRM0Vec3(item); });
    decodeValue(j, "dragForce", spring.dragForce);
    decodeValue(j, "center", spring.center);
    decodeValue(j, "hitRadius", spring.hitRadius);
    decodeValue(j, "bones", spring.bones);
    decodeValue(j, "colliderGroups", spring.colliderGroups);
    return spring;
  }

  vrm0::SecondaryAnimation
  decodeVRM0SecondaryAnimation(const nlohmann::json &j) {
    vrm0::SecondaryAnimation secondaryAnimation;
    decodeArrayWithMapElem<vrm0::SecondaryAnimationSpring>(
        j, "boneGroups", secondaryAnimation.boneGroups,
        [this](const nlohmann::json &item) {
          return decodeVRM0SecondaryAnimationSpring(item);
        });
    decodeArrayWithMapElem<vrm0::SecondaryAnimationColliderGroup>(
        j, "colliderGroups", secondaryAnimation.colliderGroups,
        [this](const nlohmann::json &item) {
          return decodeVRM0SecondaryAnimationColliderGroup(item);
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

  vrm0::Material decodeVRM0Material(const nlohmann::json &j) {
    vrm0::Material material;
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

  vrmc::SpringBoneColliderGroup
  decodeVRM1SpringBoneColliderGroup(const nlohmann::json &j) {
    vrmc::SpringBoneColliderGroup colliderGroup;
    decodeValue(j, "name", colliderGroup.name);
    decodeValue(j, "colliders", colliderGroup.colliders);
    return colliderGroup;
  }

  vrmc::SpringBoneJoint decodeVRM1SpringBoneJoint(const nlohmann::json &j) {
    vrmc::SpringBoneJoint joint;
    decodeValue(j, "node", joint.node);
    decodeValue(j, "hitRadius", joint.hitRadius);
    decodeValue(j, "stiffness", joint.stiffness);
    decodeValue(j, "gravityPower", joint.gravityPower);
    decodeValueWithMap<std::array<float, 3>>(
        j, "gravityDir", joint.gravityDir, [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 3>>();
        });
    decodeValue(j, "dragForce", joint.dragForce);
    return joint;
  }

  vrmc::SpringBoneShapeSphere
  decodeVRM1SpringBoneShapeSphere(const nlohmann::json &j) {
    vrmc::SpringBoneShapeSphere sphere;
    decodeValueWithMap<std::array<float, 3>>(
        j, "offset", sphere.offset, [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 3>>();
        });
    decodeValue(j, "radius", sphere.radius);
    return sphere;
  }

  vrmc::SpringBoneShapeCapsule
  decodeVRM1SpringBoneShapeCapsule(const nlohmann::json &j) {
    vrmc::SpringBoneShapeCapsule capsule;
    decodeValueWithMap<std::array<float, 3>>(
        j, "offset", capsule.offset, [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 3>>();
        });
    decodeValue(j, "radius", capsule.radius);
    decodeValueWithMap<std::array<float, 3>>(
        j, "tail", capsule.tail, [this](const nlohmann::json &value) {
          if (!value.is_array())
            throw InvalidFormatException(context());
          return value.get<std::array<float, 3>>();
        });
    return capsule;
  }

  vrmc::SpringBoneShape decodeVRM1SpringBoneShape(const nlohmann::json &j) {
    vrmc::SpringBoneShape shape;
    decodeObjWithMap<vrmc::SpringBoneShapeSphere>(
        j, "sphere", shape.sphere, [this](nlohmann::json value) {
          return decodeVRM1SpringBoneShapeSphere(value);
        });
    decodeObjWithMap<vrmc::SpringBoneShapeCapsule>(
        j, "capsule", shape.capsule, [this](nlohmann::json value) {
          return decodeVRM1SpringBoneShapeCapsule(value);
        });
    return shape;
  }

  vrmc::SpringBoneCollider
  decodeVRM1SpringBoneCollider(const nlohmann::json &j) {
    vrmc::SpringBoneCollider collider;
    decodeValue(j, "node", collider.node);
    decodeObjWithMap<vrmc::SpringBoneShape>(
        j, "shape", collider.shape, [this](nlohmann::json value) {
          return decodeVRM1SpringBoneShape(value);
        });
    return collider;
  }

  vrmc::SpringBoneSpring decodeVRM1SpringBoneSpring(const nlohmann::json &j) {
    vrmc::SpringBoneSpring spring;
    decodeValue(j, "name", spring.name);
    decodeArrayWithMapElem<vrmc::SpringBoneJoint>(
        j, "joints", spring.joints, [this](const nlohmann::json &item) {
          return decodeVRM1SpringBoneJoint(item);
        });
    decodeValue(j, "colliderGroups", spring.colliderGroups);
    decodeValue(j, "center", spring.center);
    return spring;
  }

  vrmc::SpringBone decodeVRM1SpringBone(const nlohmann::json &j) {
    vrmc::SpringBone springBone;
    decodeValue(j, "specVersion", springBone.specVersion);
    decodeArrayWithMapElem<vrmc::SpringBoneCollider>(
        j, "colliders", springBone.colliders,
        [this](const nlohmann::json &item) {
          return decodeVRM1SpringBoneCollider(item);
        });
    decodeArrayWithMapElem<vrmc::SpringBoneColliderGroup>(
        j, "colliderGroups", springBone.colliderGroups,
        [this](const nlohmann::json &item) {
          return decodeVRM1SpringBoneColliderGroup(item);
        });
    decodeArrayWithMapElem<vrmc::SpringBoneSpring>(
        j, "springs", springBone.springs, [this](const nlohmann::json &item) {
          return decodeVRM1SpringBoneSpring(item);
        });
    return springBone;
  }
};

} // namespace json
} // namespace gltf2

#endif /* JsonDecoder_h */
