#ifndef GLTFException_h
#define GLTFException_h

namespace gltf2 {

class GLTFException : public std::exception {
  
};

class InputException : public GLTFException {
private:
  std::string message;

public:
  InputException(const char *msg) : message(msg) {}

  const char *what() const noexcept override { return message.c_str(); }
};

class KeyNotFoundException : public GLTFException {
private:
    std::string message;

public:
    KeyNotFoundException(std::string context) : message("required: " + context) {}

    const char* what() const noexcept override {
        return message.c_str();
    }
};

class InvalidFormatException : public GLTFException {
private:
    std::string message;

public:
  InvalidFormatException(std::string context) : message("invalid format: " + context) {}

    const char* what() const noexcept override {
        return message.c_str();
    }
};

}

#endif /* GLTFException_h */
