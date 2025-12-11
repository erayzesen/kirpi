#version 330

// Uniform: The texture (algae/seaweed sprite)
uniform sampler2D texture1; 
// Uniform: Time
uniform float time; 

// Customizable Uniforms (Only amplitude, frequency, and speed remain adjustable)
uniform float amplitude;  
uniform float frequency;  
uniform float speed;      

in vec2 fragTexCoord; 
out vec4 finalColor; 

// Noise function for subtle, organic movement
float noise(vec2 coord, float scale, float offset) {
    // Combine two sine waves for complex horizontal movement
    float n1 = sin(coord.y * scale * 1.0 + time * offset * 1.0);
    float n2 = sin(coord.x * scale * 0.5 + time * offset * 0.5); 
    
    return (n1 + n2) / 2.0; 
}

void main()
{
    // --- 1. Fixed Scaling/Padding (Solving the 'Boxed In' issue) ---
    
    // We set a fixed scale to create padding.
    // 0.90 means the texture only covers 90% of the area, creating a 5% margin on all sides.
    float fixed_scale = 1.3; // Sets the texture size (e.g., 90%)
    float offset_center = (1.0 - fixed_scale) / 2.0; // Centers the texture in the remaining 10%
    
    // Apply the fixed scale and offset
    vec2 uv = fragTexCoord * fixed_scale + offset_center;
    
    // --- 2. Base Stabilization (Making the bottom of the seaweed steady) ---
    
    // Create a factor that is 0.0 at the bottom (uv.y = 1.0) and 1.0 at the top (uv.y = 0.0)
    // This ensures the distortion is strong at the top and minimal at the bottom.
    float base_fade_factor = smoothstep(0.5, 0.9, 1.0 - (uv.y-0.5)); 
    
    // --- 3. Distortion Calculation ---
    
    // Horizontal distortion (side-to-side movement)
    float distortion_x = noise(uv, frequency * 0.8, speed) * amplitude * base_fade_factor;
    
    // Vertical distortion is set to zero to prevent stretching
    float distortion_y = 0.0; 
    
    // Final distorted UV coordinates
    vec2 distortedUV = vec2(uv.x + distortion_x, uv.y + distortion_y);
    
    // --- 4. Clamping and Transparency Check ---
    // If the distorted coordinates exceed the original 0.0-1.0 boundary, discard the pixel.
    if (distortedUV.x < 0.0 || distortedUV.x > 1.0 || 
        distortedUV.y < 0.0 || distortedUV.y > 1.0) {
        
        finalColor = vec4(0.0, 0.0, 0.0, 0.0);
        return; 
    }

    // --- 5. Sampling and Output ---
    vec4 color = texture(texture1, distortedUV);
    
    finalColor = color;
}