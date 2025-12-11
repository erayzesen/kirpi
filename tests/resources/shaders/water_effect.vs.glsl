#version 330        // Raylib typically uses GLSL 330 or higher

// Input Attributes (Raylib tarafından otomatik olarak sağlanır)
in vec3 vertexPosition; // The position of the vertex
in vec2 vertexTexCoord; // The texture coordinates of the vertex
in vec3 vertexColor;    // The color of the vertex (though usually WHITE for texture drawing)

// Uniforms (Raylib tarafından otomatik olarak sağlanır)
uniform mat4 mvp;       // Model-View-Projection matrix (Dönüşüm matrisi)

// Output to Fragment Shader
out vec2 fragTexCoord;  // Pass the texture coordinate to the fragment shader
out vec4 fragColor;     // Pass the color (usually white)

void main()
{
    // 1. Calculate the final position of the vertex in clip space
    // Standard operation: position = mvp * vertex_position
    gl_Position = mvp * vec4(vertexPosition, 1.0);

    // 2. Pass the texture coordinates and color unchanged to the fragment shader
    fragTexCoord = vertexTexCoord;
    fragColor = vec4(vertexColor, 1.0); // Pass color
}