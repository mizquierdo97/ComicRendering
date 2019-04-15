Shader "Custom/CustomSurface" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Intensity("Intensity", Range(0,1)) = 1.0

		_BOctaves(" Big Noise Octaves", Float) = 9.6
		_BFrequency(" Big Noise Frequency", Float) = 1.0
		_BAmplitude(" Big Noise Amplitude", Float) = 1.0
		_BLacunarity(" Big Noise Lacunarity", Float) = 1.92
		_BPersistence(" Big Noise Persistence", Float) = 0.8

		_SOctaves("Small Noise Octaves", Float) = 9.6
		_SFrequency("Small Noise Frequency", Float) = 1.0
		_SAmplitude("Small Noise Amplitude", Float) = 1.0
		_SLacunarity("Small Noise Lacunarity", Float) = 1.92
		_SPersistence("Small Noise Persistence", Float) = 0.8
		_Div("DepthInstensity", Float) = 1.0
		[MaterialToggle] _UsingNoise("Using Noise", Float) = 1.0
		[MaterialToggle] _HUE("HUE Shift", Float) = 1.0
	}

		CGINCLUDE

		//NOISE GENERATION
		
			void FAST32_hash_3D(float3 gridcell,
				out float4 lowz_hash_0,
				out float4 lowz_hash_1,
				out float4 lowz_hash_2,
				out float4 highz_hash_0,
				out float4 highz_hash_1,
				out float4 highz_hash_2)		//	generates 3 random numbers for each of the 8 cell corners
		{


			const float2 OFFSET = float2(50.0, 161.0);
			const float DOMAIN = 69.0;
			const float3 SOMELARGEFLOATS = float3(635.298681, 682.357502, 668.926525);
			const float3 ZINC = float3(48.500388, 65.294118, 63.934599);

			//	truncate the domain
			gridcell.xyz = gridcell.xyz - floor(gridcell.xyz * (1.0 / DOMAIN)) * DOMAIN;
			float3 gridcell_inc1 = step(gridcell, float3(DOMAIN - 1.5, DOMAIN - 1.5, DOMAIN - 1.5)) * (gridcell + 1.0);

			//	calculate the noise
			float4 P = float4(gridcell.xy, gridcell_inc1.xy) + OFFSET.xyxy;
			P *= P;
			P = P.xzxz * P.yyww;
			float3 lowz_mod = float3(1.0 / (SOMELARGEFLOATS.xyz + gridcell.zzz * ZINC.xyz));
			float3 highz_mod = float3(1.0 / (SOMELARGEFLOATS.xyz + gridcell_inc1.zzz * ZINC.xyz));
			lowz_hash_0 = frac(P * lowz_mod.xxxx);
			highz_hash_0 = frac(P * highz_mod.xxxx);
			lowz_hash_1 = frac(P * lowz_mod.yyyy);
			highz_hash_1 = frac(P * highz_mod.yyyy);
			lowz_hash_2 = frac(P * lowz_mod.zzzz);
			highz_hash_2 = frac(P * highz_mod.zzzz);
		}

		float3 Interpolation_C2(float3 x) { return x * x * x * (x * (x * 6.0 - 15.0) + 10.0); }

		float Perlin3D(float3 P)
		{
			//	establish our grid cell and unit position
			float3 Pi = floor(P);
			float3 Pf = P - Pi;
			float3 Pf_min1 = Pf - 1.0;

			float4 hashx0, hashy0, hashz0, hashx1, hashy1, hashz1;
			FAST32_hash_3D(Pi, hashx0, hashy0, hashz0, hashx1, hashy1, hashz1);

			//	calculate the gradients
			float4 grad_x0 = hashx0 - 0.49999;
			float4 grad_y0 = hashy0 - 0.49999;
			float4 grad_z0 = hashz0 - 0.49999;
			float4 grad_x1 = hashx1 - 0.49999;
			float4 grad_y1 = hashy1 - 0.49999;
			float4 grad_z1 = hashz1 - 0.49999;
			float4 grad_results_0 = rsqrt(grad_x0 * grad_x0 + grad_y0 * grad_y0 + grad_z0 * grad_z0) * (float2(Pf.x, Pf_min1.x).xyxy * grad_x0 + float2(Pf.y, Pf_min1.y).xxyy * grad_y0 + Pf.zzzz * grad_z0);
			float4 grad_results_1 = rsqrt(grad_x1 * grad_x1 + grad_y1 * grad_y1 + grad_z1 * grad_z1) * (float2(Pf.x, Pf_min1.x).xyxy * grad_x1 + float2(Pf.y, Pf_min1.y).xxyy * grad_y1 + Pf_min1.zzzz * grad_z1);

			//	Classic Perlin Interpolation
			float3 blend = Interpolation_C2(Pf);
			float4 res0 = lerp(grad_results_0, grad_results_1, blend.z);
			float2 res1 = lerp(res0.xy, res0.zw, blend.y);
			float final = lerp(res1.x, res1.y, blend.x);
			final *= 1.1547005383792515290182975610039;		//	(optionally) scale things to a strict -1.0->1.0 range    *= 1.0/sqrt(0.75)
			return final;
		}
		float PerlinNormal(float3 p, int octaves, float3 offset, float frequency, float amplitude, float lacunarity, float persistence)
		{
			float sum = 0;
			for (int i = 0; i < octaves; i++)
			{
				float h = 0;
				h = Perlin3D((p + offset) * frequency);
				sum += h * amplitude;
				frequency *= lacunarity;
				amplitude *= persistence;
			}
			return sum;
		}
		
		//

		float3 Saturation(float _saturation, float3 col)
		{
			return float3(0.5 * (1 - _saturation) + col.r * _saturation, 0.5 * (1 - _saturation) + col.g * _saturation, 0.5 * (1 - _saturation) + col.b * _saturation);
		}

		//COLOR HSV
		
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
					delRGB = (HSV.zzz - RGB + 3 * delta) / (6.0*delta);
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
		
		//

		ENDCG

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
					   			 
			CGPROGRAM
#pragma surface surf WrapLambert vertex:vert
					#pragma glsl
		#pragma target 3.5

		//Input Parameters
		float4 _Color;
		sampler2D _MainTex;
		fixed _BOctaves;
		float _BFrequency;
		float _BAmplitude;
		float3 _BOffset;
		float _BLacunarity;
		float _BPersistence;
		fixed _SOctaves;
		float _SFrequency;
		float _SAmplitude;
		float3 _SOffset;
		float _SLacunarity;
		float _SPersistence;
		bool _UsingNoise;
		bool _HUE;

		float _Div;
			half4 LightingWrapLambert(SurfaceOutput s, half3 lightDir, half atten) {
			half NdotL = dot(s.Normal, lightDir);	
			float firstSlope = 0.5;
			float secondSlope = 0.4;
			float thirdSlope = -0.5;
			float fourthSlope = -0.6;

			float mainIntensity = 1.0f;
			float secondIntensity = 0.5;
			float thirdIntensity = 0.5;
			float saturation = 1.0f;			

			if (NdotL <= firstSlope)
			{
				
				if (NdotL > secondSlope)
				{
					saturation = ((NdotL - secondSlope) / (firstSlope - secondSlope)) * 1.0f + (1 - (NdotL - secondSlope) / (firstSlope - secondSlope)) * 2.0f;
					NdotL = ((NdotL - secondSlope) / (firstSlope - secondSlope) ) * mainIntensity + (1 - (NdotL - secondSlope)/ (firstSlope - secondSlope)) * secondIntensity;
					
					
				}
				else
				{
					if (NdotL > thirdSlope)
					{
						NdotL = secondIntensity;
						saturation = 2.0f;
					}
					else
					{
						if (NdotL > fourthSlope)
						{
							NdotL = ((NdotL - fourthSlope) / (thirdSlope - fourthSlope) ) * secondIntensity + (1 - (NdotL - fourthSlope)/ (thirdSlope - fourthSlope)) * thirdIntensity;
							saturation = 2.0f;
						}
						else
						{
							NdotL = thirdIntensity;
							saturation = 2.0f;
						}
					}
				}
			}
			else NdotL = mainIntensity;

			float3 color = s.Albedo;

			//COLOR HUE SHIFT
			if (_HUE)
			{
				float3 hsv = rgb_to_hsv_no_clip(Saturation(saturation, color.xyz * clamp(color, 0.0, 1)));
				hsv.x += (saturation - 1) / 8;
				if (hsv.x > 1.0) { hsv.x -= 1.0; }
				color = half3(hsv_to_rgb(hsv)) * 1;
			}
			//

			half4 ret;
			ret.rgb =  (color * _LightColor0.rgb * (NdotL * atten));
			ret.a = s.Alpha;
			return ret;
		}


		struct Input {
			float3 pos;
			float depth;
			float3 objPos;
			float2 uv_MainTex;
		};
		

		sampler2D_float _CameraDepthTexture;
		float4 _CameraDepthTexture_TexelSize;

		void vert(inout appdata_full v, out Input OUT)
		{
			UNITY_INITIALIZE_OUTPUT(Input, OUT);		

			//WORLD PIXEL POSITION
			OUT.pos = mul(unity_ObjectToWorld, v.vertex).xyz;

			//WORLD OBJECT POSITION
			OUT.objPos =  mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz;

			//DEPTH
			COMPUTE_EYEDEPTH(OUT.depth);
		}

		void surf(Input IN, inout SurfaceOutput o) {

			//TEXTURE
			float3 tex = tex2D(_MainTex, IN.uv_MainTex);

			//DEPTH
			float depth =  IN.depth;

			//COLOR * TEXTURE
			float3 color = _Color *tex;

			//OBJEXT POSITION
			float3 objPos = IN.objPos;

			if (!_UsingNoise)
			{
				o.Albedo = color;
				return;
			}
			float smallNoise = PerlinNormal(IN.pos, _SOctaves, objPos, _SFrequency, _SAmplitude, _SLacunarity, _SPersistence);
			smallNoise = clamp(smallNoise, 0, 1);

			float bigNoise = PerlinNormal(IN.pos, _BOctaves, objPos, _BFrequency, _BAmplitude - (depth / (_Div * 2)), _BLacunarity, _BPersistence + (depth / _Div));
			
			//Maybe not needed
			float noiseColor;
			noiseColor = PerlinNormal(IN.pos, _BOctaves, _BOffset, _BFrequency / 10, _BAmplitude, _BLacunarity, _BPersistence);

			//////

			bigNoise = bigNoise / 3;

			float3 col = color * 0.4;
			if (bigNoise > 0.9) col  = color * 0.8;
			else if (bigNoise < (0.87 - (depth / _Div)) && smallNoise < 0.75) col = color;
			else if (smallNoise >= 0.8) col = color * 0.5;

			noiseColor = clamp(noiseColor, 0, 1);

			o.Albedo = col;// *(1 - (depth / 300));

		}
		ENDCG
	}
	FallBack "Diffuse"
}
