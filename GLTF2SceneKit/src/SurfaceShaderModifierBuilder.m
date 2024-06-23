#import "SurfaceShaderModifierBuilder.h"

@implementation SurfaceShaderModifierBuilder

- (NSString *)buildShader {
  NSMutableString *shader = [NSMutableString string];

  if (self.transparent) {
    [shader appendString:@"#pragma transparent\n"];
  }

  NSArray<NSString *> *uniforms = @[
    @"vec4  diffuseBaseColorFactor",
    @"float diffuseAlphaCutoff",

    @"float anisotropyStrength",
    @"float anisotropyRotation",
    @"sampler2D anisotropyTexture",

    @"vec3  sheenColorFactor",
    @"float sheenRoughnessFactor",
    @"sampler2D sheenColorTexture",
    @"sampler2D sheenRoughnessTexture",

    @"float emissiveStrength",

    @"float ior",
  ];
  for (NSString *uniform in uniforms) {
    [shader appendString:[@[ @"uniform ", uniform, @";" ]
                             componentsJoinedByString:@""]];
  }

  [shader appendString:@"\n"
                        "vec3 F_Schlick(vec3 f0, vec3 f90, float VdotH) {"
                        "  return f0 + (f90 - f0) * pow("
                        "    clamp(1.0 - VdotH, 0.0, 1.0), 5.0"
                        "  );"
                        "}"
                        "\n"];

  // anisotropy
  [shader appendFormat:
              @"\n"
               "float D_GGX_anisotropic("
               "  float NdotH, float TdotH, float BdotH,"
               "  float at, float ab"
               ") {"
               "  float a2 = at * ab;"
               "  vec3 f = vec3(ab * TdotH, at * BdotH, a2 * NdotH);"
               "  float w2 = a2 / dot(f, f);"
               "  return a2 * w2 * w2 / %f;"
               "}"
               "\n"
               "float V_GGX_anisotropic("
               "  float NdotL, float NdotV, float BdotV, "
               "  float TdotV, float TdotL, float BdotL, float at, float ab"
               ") {"
               "  float GGXV = NdotL * length("
               "    vec3(at * TdotV, ab * BdotV, NdotV)"
               "  );"
               "  float GGXL = NdotV * length("
               "    vec3(at * TdotL, ab * BdotL, NdotL)"
               "  );"
               "  float v = 0.5 / (GGXV + GGXL);"
               "  return clamp(v, 0.0, 1.0);"
               "}"
               "\n"
               "vec3 BRDF_specularAnisotropicGGX("
               "  vec3 f0, vec3 f90, float alphaRoughness,"
               "  float VdotH, float NdotL, float NdotV, "
               "  float NdotH, float BdotV, float TdotV,"
               "  float TdotL, float BdotL, float TdotH, "
               "  float BdotH, float anisotropy"
               ") {"
               "  float at = mix(alphaRoughness, 1.0, anisotropy * anisotropy);"
               "  float ab = alphaRoughness;"
               "  vec3 F = F_Schlick(f0, f90, VdotH);"
               "  float V = V_GGX_anisotropic("
               "    NdotL, NdotV, BdotV, TdotV,"
               "    TdotL, BdotL, at, ab"
               "  );"
               "  float D = D_GGX_anisotropic(NdotH, TdotH, BdotH, at, ab);"
               "  return F * V * D * %f * NdotL;"
               "}"
               "\n",
              M_PI, M_PI];

  // sheen
  // Charlie distribution and Ashikhmin visibility
  [shader
      appendFormat:
          @"\n"
           "float D_Sheen(float alphaG, float NdotH) {"
           "  float invR = 1. / alphaG;"
           "  float cos2h = NdotH * NdotH;"
           "  float sin2h = 1. - cos2h;"
           "  return (2. + invR) * pow(sin2h, invR * .5) / (2. * %f);"
           "}"
           "\n"
           "float l(float x, float alphaG) {"
           "  float oneMinusAlphaSq = (1.0 - alphaG) * (1.0 - alphaG);"
           "  float a = mix(21.5473, 25.3245, oneMinusAlphaSq);"
           "  float b = mix(3.82987, 3.32435, oneMinusAlphaSq);"
           "  float c = mix(0.19823, 0.16801, oneMinusAlphaSq);"
           "  float d = mix(-1.97760, -1.27393, oneMinusAlphaSq);"
           "  float e = mix(-4.32054, -4.85967, oneMinusAlphaSq);"
           "  return a / (1.0 + b * pow(x, c)) + d * x + e;"
           "}"
           "\n"
           "float lambdaSheen(float cosTheta, float alphaG) {"
           "  if (abs(cosTheta) < 0.5) {"
           "    return exp(l(cosTheta, alphaG));"
           "  } else {"
           "    return exp(2.0 * l(0.5, alphaG) - "
           "l(1.0 - cosTheta, alphaG));"
           "  }"
           "}"
           "\n"
           "float V_Sheen(float alphaG, float NdotV, float NdotL) {"
           "  return clamp(1.0 / ((1.0 + lambdaSheen(NdotV, alphaG) + "
           "lambdaSheen(NdotL, alphaG)) * (4.0 * NdotV * NdotL)), 0.0, 1.0);"
           "}"
           "\n"
           "\n"
           "vec3 BRDF_specularSheen("
           "  float sheenRoughness, "
           "  float NdotL, float NdotV, float NdotH "
           ") {"
           "  float roughness = max(sheenRoughness, 0.000001);"
           "  float alphaG = roughness * roughness;"
           "  float D = D_Sheen(alphaG, NdotH);"
           "  float V = V_Sheen(alphaG, NdotV, NdotL);"
           "  return D * V * %f * NdotL;"
           "}"
           "\n",
          M_PI, M_PI];

  // Body
  [shader appendString:@"#pragma body\n"];

  [shader appendString:@"vec3 f0 = vec3(pow((ior - 1)/(ior + 1), 2));"
                        "vec3 f90 = vec3(1.0);"
                        "float metalness = _surface.metalness;"
                        "float roughness = _surface.roughness;"
                        "float alphaRoughness = 0.0;"
                        "vec4 baseColor = _surface.diffuse;"
                        "_surface.emission *= emissiveStrength;"];

  if (self.hasBaseColorTexture) {
    [shader appendString:@"baseColor *= diffuseBaseColorFactor;"];
  }

  [shader appendString:@"alphaRoughness = roughness * roughness;"
                        "f0 = mix(f0, baseColor.rgb, metalness);"];

  if (self.enableAnisotropy) {
    [shader appendString:@"if (true) {"
                          "  vec2 u_AnisotropyRotation = vec2("
                          "    cos(anisotropyRotation),"
                          "    sin(anisotropyRotation)"
                          "  );"
                          "  vec2 direction = u_AnisotropyRotation;"
                          "  float anisotropy = anisotropyStrength;"];
    if (self.hasAnisotropyTexture) {
      [shader appendString:@"  vec3 anisotropyTex = texture2D("
                            "    anisotropyTexture, "
                            "    _surface.diffuseTexcoord" // surface modifier
                                                           // cannot
                            // get texcoords. so we use
                            // diffuseTexcoord instead
                            "  ).rgb;"
                            "  direction = anisotropyTex.rg * 2.0 - vec2(1.0);"
                            "  direction = mat2(u_AnisotropyRotation.x,"
                            "                   u_AnisotropyRotation.y,"
                            "                   -u_AnisotropyRotation.y,"
                            "                   u_AnisotropyRotation.x"
                            "  ) * normalize(direction);"
                            "  anisotropy = anisotropyTex.b;"];
    }
    [shader appendString:
                @"  vec3 N = normalize(_surface.normal);"
                 "  vec3 V = normalize(_surface.view);"
                 "  vec3 L = normalize(scn_lights[0].pos - _surface.position);"
                 "  vec3 H = normalize(V + L);"
                 "  vec3 T = normalize(_surface.tangent);"
                 "  vec3 B = normalize(cross(N, T));"
                 "  mat3 TBN = mat3(T, B, N);"
                 "  vec3 anisotropicT = normalize(TBN * vec3(direction, 0.0));"
                 "  vec3 anisotropicB = normalize(cross(N, anisotropicT));"
                 "  float VdotH = max(dot(V, H), 0.0);\n"
                 "  float NdotL = max(dot(N, L), 0.0);\n"
                 "  float NdotV = max(dot(N, V), 0.0);\n"
                 "  float NdotH = max(dot(N, H), 0.0);\n"
                 "  float BdotV = max(dot(anisotropicB, V), 0.0);\n"
                 "  float TdotV = max(dot(anisotropicT, V), 0.0);\n"
                 "  float TdotL = max(dot(anisotropicT, L), 0.0);\n"
                 "  float BdotL = max(dot(anisotropicB, L), 0.0);\n"
                 "  float TdotH = max(dot(anisotropicT, H), 0.0);\n"
                 "  float BdotH = max(dot(anisotropicB, H), 0.0);\n"
                 "  vec3 brdf = BRDF_specularAnisotropicGGX("
                 "    f0, f90, alphaRoughness,"
                 "    VdotH, NdotL, NdotV, "
                 "    NdotH, BdotV, TdotV, "
                 "    TdotL, BdotL, TdotH, "
                 "    BdotH, anisotropy"
                 "  );\n"
                 "  baseColor.rgb += brdf;"
                 "}"
                 "\n"];
  }

  if (self.enableSheen) {
    [shader appendString:
                @"if (true) {"
                 "  vec3 N = normalize(_surface.normal);"
                 "  vec3 V = normalize(_surface.view);"
                 "  vec3 L = normalize(scn_lights[0].pos - _surface.position);"
                 "  vec3 H = normalize(V + L);"
                 "  float NdotL = max(dot(N, L), 0.0);"
                 "  float NdotV = max(dot(N, V), 0.0);"
                 "  float NdotH = max(dot(N, H), 0.0);"
                 "  float VdotH = max(dot(V, H), 0.0);"
                 "  vec3 sheenColor = sheenColorFactor;"
                 "  float sheenRoughness = sheenRoughnessFactor;\n"];

    if (self.hasSheenColorTexture) {
      [shader appendString:
                  @"  sheenColor = texture2D("
                   "    sheenColorTexture, "
                   "    _surface.diffuseTexcoord" // surface modifier cannot
                                                  // get texcoords. so we use
                                                  // diffuseTexcoord instead
                   "  ).rgb;"
                   "  sheenColor *= sheenColorFactor;"];
    }
    if (self.hasSheenRoughnessTexture) {
      [shader appendString:
                  @"  sheenRoughness = texture2D("
                   "    sheenRoughnessTexture, "
                   "    _surface.diffuseTexcoord" // surface modifier cannot
                                                  // get texcoords. so we use
                                                  // diffuseTexcoord instead
                   "  ).a;"
                   "  sheenRoughness *= sheenRoughnessFactor;"];
    }

    [shader appendString:@"\n"
                          "  vec3 sheen_brdf = BRDF_specularSheen("
                          "    sheenRoughness,"
                          "    NdotL, NdotV, NdotH"
                          "  );"
                          "  baseColor.rgb += sheenColor * sheen_brdf;"
                          "}\n"];
  }
  [shader appendString:@"_surface.diffuse = baseColor;"
                        "_surface.metalness = metalness;"
                        "_surface.roughness = roughness;"];

  if (self.isDiffuseOpaque) {
    [shader appendString:@"_surface.diffuse.a = 1.0;"];
  } else if (self.enableDiffuseAlphaCutoff) {
    [shader appendString:@"_surface.diffuse.a = _surface.diffuse.a < "
                          "diffuseAlphaCutoff ? 0.0 : 1.0;"];
  }
  return shader;
}

@end
