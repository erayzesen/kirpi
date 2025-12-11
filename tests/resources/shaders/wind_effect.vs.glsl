#version 330

// Vertex attributes
layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec2 vertexTexCoord;

// Uniforms
uniform mat4 mvp;   // Model-View-Projection
uniform float time;  
uniform float amount=20;

out vec2 fragTexCoord;

void main() {
    vec3 pos = vertexPosition;
    
    float normalizedY = vertexTexCoord.y; 

    float windWave = sin(normalizedY * 3.0 + time * 2.0)*amount; 
    
    float heightMultiplier = 1.0 - normalizedY; 

    float sway = windWave * heightMultiplier * 0.15; 
    
    pos.x += sway;

    fragTexCoord = vertexTexCoord;
    gl_Position = mvp * vec4(pos, 1.0);
}
