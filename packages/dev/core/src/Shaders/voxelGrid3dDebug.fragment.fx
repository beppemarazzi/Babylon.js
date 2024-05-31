precision highp sampler3D;

varying vec2 vUV;

uniform sampler3D voxelTexture;
uniform sampler2D voxelSlabTexture;
uniform sampler2D textureSampler;

uniform vec4 sizeParams;
#define offsetX sizeParams.x
#define offsetY sizeParams.y
#define widthScale sizeParams.z
#define heightScale sizeParams.w
uniform float mipNumber;

void main(void) {

    vec2 uv =
        vec2((offsetX + vUV.x) * widthScale, (offsetY + vUV.y) * heightScale);
    vec4 background = texture2D(textureSampler, vUV);
    vec4 voxelSlab = texture2D(voxelSlabTexture, vUV);

    // ***** Display all slices as a grid *******
    ivec3 size = textureSize(voxelTexture, int(mipNumber));
    float dimension = ceil(sqrt(float(size.z)));
    vec2 samplePos = fract(uv.xy * vec2(dimension));
    int sampleIndex = int(floor(uv.x * float(dimension)) +
                          floor(uv.y * float(dimension)) * dimension);
    bool outBounds = sampleIndex > size.z - 1 ? true : false;
    sampleIndex = clamp(sampleIndex, 0, size.z - 1);
    // vec3 voxel =
    //     textureLod(voxelTexture,
    //                vec3(samplePos.xy, float(sampleIndex) / float(size.z)),
    //                mipNumber)
    //         .rgb;
    ivec2 samplePosInt = ivec2(samplePos.xy * vec2(size.xy));
    vec3 voxel = texelFetch(voxelTexture,
                            ivec3(samplePosInt.x, samplePosInt.y, sampleIndex),
                            int(mipNumber))
                     .rgb;

    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
      gl_FragColor.rgba = background;
    } else {
      if (outBounds) {
        voxel = vec3(0.15, 0.0, 0.0);
      }
      glFragColor.rgb = mix(background.rgb, voxelSlab.rgb, 0.5) + voxel;

      glFragColor.a = 1.0;
      // glFragColor.rgb += texture(textureSampler, vUV.xy).rgb;
    }
}