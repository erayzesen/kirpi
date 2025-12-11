#version 330

uniform sampler2D texture1; 
uniform float time; 

in vec2 fragTexCoord; 
out vec4 finalColor; 

// Dalgalanma miktarını kontrol etmek için uniform kullanabiliriz
// uniform float u_max_distortion; 

void main()
{
    // Orijinal (non-scaled) koordinatlar
    vec2 uv = fragTexCoord;

    // --- 1. Dalga Efekti ---
    // Dalgalanma miktarı (Bu, texture koordinatını 0.0-1.0 kutusunun dışına taşır)
    float distortion_amount = 0.02; // Dalgalanmanın maksimum genliği (2 birimlik pay)
    
    float wave1 = sin(uv.y * 30.0 + time * 2.0) * distortion_amount; 
    float wave2 = cos(uv.x * 20.0 + time * 1.5) * distortion_amount * 1.5; // Biraz daha farklı bir hız
    
    vec2 distortedUV = vec2(uv.x , uv.y + wave2-0.1);
    
    // --- 2. Sınırlandırma ve Şeffaflık Kontrolü (Hata Giderme) ---
    
    // Eğer çarpıtılmış koordinatlar 0.0'dan küçük veya 1.0'dan büyükse, 
    // yani dalgalanma kutunun dışına çıktıysa, o pikselleri ŞEFFAF yap.
    if (distortedUV.x < 0.0 || distortedUV.x > 1.0 || 
        distortedUV.y < 0.0 || distortedUV.y > 1.0) {
        
        // Discard: Pikselleri tamamen at (Daha kesin bir şeffaflık sağlar, isteğe bağlıdır)
        // discard; 
        
        finalColor = vec4(0.0, 0.0, 0.0, 0.0); // Tamamen şeffaf (Alpha = 0)
        return; 
    }

    // --- 3. Texture Örnekleme ve Çıktı ---
    vec4 color = texture(texture1, distortedUV);
    
    finalColor = color;
}