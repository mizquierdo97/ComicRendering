Shader "Hidden/DistortionShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_SOctaves("Small Noise Octaves", Float) = 9.6
		_SFrequency("Small Noise Frequency", Float) = 1.0
		_SAmplitude("Small Noise Amplitude", Float) = 1.0
		_SLacunarity("Small Noise Lacunarity", Float) = 1.92
		_SPersistence("Small Noise Persistence", Float) = 0.8
		_Div("DepthInstensity", Float) = 1.0
	}

		CGINCLUDE


		

	

	//

	ENDCG

	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			sampler2D _CameraDepth;
			sampler2D _DistortionTexture;
			int _Type;
			float _Intensity;
			float _IntensityHigh;
			sampler2D _WorldPosTex;

			fixed _SOctaves;
			float _SFrequency;
			float _SAmplitude;
			float3 _SOffset;
			float _SLacunarity;
			float _SPersistence;
			uniform float4 _MainTex_TexelSize;

			float3 Saturation(float _saturation, float3 col)
			{
				float P = sqrt(col.r * col.r + col.g * col.g + col.b * col.b);
				return float3(P + ((col.r - P) * _saturation), P + ((col.g - P) * _saturation), P + ((col.b - P) * _saturation));
				return float3(0.5 * (1 - _saturation) + col.r * _saturation, 0.5 * (1 - _saturation) + col.g * _saturation, 0.5 * (1 - _saturation) + col.b * _saturation);
			}


			float3 rgb_to_hsv_no_clip(float3 RGB)
			{
				float3 HSV;

				float minChannel, maxChannel;
				if (RGB.x > RGB.y) {
					maxChannel = RGB.x;
					minChannel = RGB.y;
				}
				else {
					maxChannel = RGB.y;
					minChannel = RGB.x;
				}

				if (RGB.z > maxChannel) maxChannel = RGB.z;
				if (RGB.z < minChannel) minChannel = RGB.z;

				HSV.xy = 0;
				HSV.z = maxChannel;
				float delta = maxChannel - minChannel;             //Delta RGB value
				if (delta != 0) {                    // If gray, leave H  S at zero
					HSV.y = delta / HSV.z;
					float3 delRGB;
					delRGB = (HSV.zzz - RGB + 3 * delta) / (6.0 * delta);
					if (RGB.x == HSV.z) HSV.x = delRGB.z - delRGB.y;
					else if (RGB.y == HSV.z) HSV.x = (1.0 / 3.0) + delRGB.x - delRGB.z;
					else if (RGB.z == HSV.z) HSV.x = (2.0 / 3.0) + delRGB.y - delRGB.x;
				}
				return (HSV);
			}
			float3 hsv_to_rgb(float3 HSV)
			{
				float3 RGB = HSV.z;

				float var_h = HSV.x * 6;
				float var_i = floor(var_h);   // Or ... var_i = floor( var_h )
				float var_1 = HSV.z * (1.0 - HSV.y);
				float var_2 = HSV.z * (1.0 - HSV.y * (var_h - var_i));
				float var_3 = HSV.z * (1.0 - HSV.y * (1 - (var_h - var_i)));
				if (var_i == 0) { RGB = float3(HSV.z, var_3, var_1); }
				else if (var_i == 1) { RGB = float3(var_2, HSV.z, var_1); }
				else if (var_i == 2) { RGB = float3(var_1, HSV.z, var_3); }
				else if (var_i == 3) { RGB = float3(var_1, var_2, HSV.z); }
				else if (var_i == 4) { RGB = float3(var_3, var_1, HSV.z); }
				else { RGB = float3(HSV.z, var_1, var_2); }

				return (RGB);
			}

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;

			fixed4 frag (v2f i) : SV_Target
			{
				float2 delta = _MainTex_TexelSize;
				float intensity = _Intensity;
				float size = 4.0f;
				if (_Type == 1)
				{
					size = 0.8f;
					intensity = _Intensity;
				}

				float3 wp = tex2D(_WorldPosTex, i.uv);
				float3 noise = tex2D(_DistortionTexture,i.uv * size/* wp.xy * 0.1f*/);
				float depth1 = tex2D(_CameraDepth, i.uv + float2(delta.x, delta.y));
				float depth2 = tex2D(_CameraDepth, i.uv + float2(-delta.x, delta.y));
				float depth3 = tex2D(_CameraDepth, i.uv + float2(delta.x, -delta.y) );
				float depth4 = tex2D(_CameraDepth, i.uv + float2(-delta.x, -delta.y));
				//float depth = (depth1 + depth2 + depth3 + depth4) / 4;
				float depth = min(depth1, min(depth2, min(depth3, depth4)));// min(1, min(depth1, min(depth2, min(depth3, depth4))) + 0.2);
				//depth = tex2D(_CameraDepth, i.uv);
				//float size = 5.0f;

				float minAmplitude = 0.0f;
				
				float offset = 0.25;


				fixed NoiseX = noise.x;
				fixed NoiseY = noise.y;

				if (_Type == 2)
				{
					NoiseX = noise.y;
					NoiseY = noise.z;
				}
				if (_Type == 3)
				{
					NoiseX = noise.z;
					NoiseY = noise.x;
				}
				if (_Type != 1)
				{
					NoiseX = clamp(NoiseX - offset, 0, 1);
					NoiseX = NoiseX * 2 - 1;
					NoiseY = clamp(NoiseY - offset, 0, 1);
					NoiseY = NoiseY * 2 - 1;
				}
				if (_Type == 1)
				{
					float power = 20;
					NoiseX = pow(NoiseX, power);
					NoiseY = pow(NoiseY, power);
				}
				
				float distortionX = clamp(NoiseX, -1, 1);
				float distortionY = clamp(NoiseY, -1, 1);
				depth = tex2D(_CameraDepth,float2(i.uv.x + distortionX * delta.x * intensity, i.uv.y + distortionY * delta.y * intensity));
				fixed4 col = tex2D(_MainTex, float2(i.uv.x + distortionX * delta.x * intensity/* * depth*/, i.uv.y + distortionY * delta.y * intensity/* * depth*/));
				//col *= multiply;
				float3 noiseColor;
				if (_Type == 0)
				{
					float3 a;
					float depthclamp = (pow(depth * 20, 0.7));
					noiseColor = tex2D(_DistortionTexture, i.uv / clamp(depthclamp, 0, 3)/* wp.xy * 0.1f*/);
					noiseColor = clamp(noiseColor - 0.2, 0, 1);
					noiseColor = pow(noiseColor, 1);
					noiseColor = noiseColor * 2 - 1;
					//saturation = max(1, saturation * _ShadowIntensity);
					float3 hsv = rgb_to_hsv_no_clip(Saturation(clamp(noiseColor.x * 1, 0.9,1.2), col.rgb));
					hsv.x += ( noiseColor *1) / 8;
					if (hsv.x > 1.0) { hsv.x -= 1.0; }
					col.xyz = half3(hsv_to_rgb(hsv)) ;

				}
				//return depth;
			
				return col;// float4(depth.x, depth.x, depth.x, 1);// float4(noiseColor, 1);// float4(noise, 1);
			}
			ENDCG
		}
	}
}
