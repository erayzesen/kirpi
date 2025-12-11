#version 330

// Uniform: The texture for the current layer (e.g., background, midground)
uniform sampler2D texture1; 
// Uniform: The camera's total movement/offset along the X-axis (from C/C++)
uniform float time; 
// Uniform: The depth factor for this specific layer (Determines speed)
// Closer layers should have a higher factor (e.g., 0.5)
// Farther layers should have a lower factor (e.g., 0.1)

in vec2 fragTexCoord; 
out vec4 finalColor; 

void main()
{
    
    float shift_x = time*0.01 ; 
    
    
    vec2 parallaxUV = vec2(fragTexCoord.x + shift_x, fragTexCoord.y);

    vec4 color = texture(texture1, parallaxUV);

    finalColor = color;
}