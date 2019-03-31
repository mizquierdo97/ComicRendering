Shader "Custom/CustomSurface" {

	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Intensity("Intensity", Range(0,1)) = 1.0

		_BOctaves(" Big Noise Octaves", Float) = 9.6
		_BFrequency(" Big Noise Frequency", Float) = 1.0
		_BAmplitude(" Big Noise Amplitude", Float) = 1.0
		_BLacunarity(" Big Noise Lacunarity", Float) = 1.92
		_BPersistence(" Big Noise Persistence", Float) = 0.8
		_BOffset(" Big Noise Offset", Vector) = (0.0, 0.0, 0.0, 0.0)

		_SOctaves("Small Noise Octaves", Float) = 9.6
		_SFrequency("Small Noise Frequency", Float) = 1.0
		_SAmplitude("Small Noise Amplitude", Float) = 1.0
		_SLacunarity("Small Noise Lacunarity", Float) = 1.92
		_SPersistence("Small Noise Persistence", Float) = 0.8
		_SOffset("Small Noise Offset", Vector) = (0.0, 0.0, 0.0, 0.0)
		_Div("DepthInstensity", Float) = 1.0
	}

		CGINCLUDE
			//Noise
			void FAST32_hash_3D(float3 gridcell,
				out float4 lowz_hash_0,
				out float4 lowz_hash_1,
				out float4 lowz_hash_2,
				out float4 highz_hash_0,
				out float4 highz_hash_1,
				out float4 highz_hash_2)		//	generates 3 random numbers for each of the 8 cell corners
		{
			//    gridcell is assumed to be an integer coordinate

			//	TODO: 	these constants need tweaked to find the best possible noise.
			//			probably requires some kind of brute force computational searching or something....
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

			//
			//	classic noise.
			//	requires 3 random values per point.  with an efficent hash function will run faster than improved noise
			//

			//	calculate the hash.
			//	( various hashing methods listed in order of speed )
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

		ENDCG

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
					   			 
			CGPROGRAM
#pragma surface surf WrapLambert vertex:vert
					#pragma glsl
		#pragma target 3.0

			half4 LightingWrapLambert(SurfaceOutput s, half3 lightDir, half atten) {
			half NdotL = dot(s.Normal, lightDir);	
			float firstSlope = 0.5;
			float secondSlope = 0.4;
			float thirdSlope = -0.5;
			float fourthSlope = -0.6;

			float mainIntensity = 1.0f;
			float secondIntensity = 0.5;
			float thirdIntensity = 0.5;
			if (NdotL <= firstSlope)
			{
				
				if (NdotL > secondSlope)
				{
					NdotL = ((NdotL - secondSlope) / (firstSlope - secondSlope) ) * mainIntensity + (1 - (NdotL - secondSlope)/ (firstSlope - secondSlope)) * secondIntensity;
				}
				else
				{
					if (NdotL > thirdSlope)
					{
						NdotL = secondIntensity;
					}
					else
					{
						if (NdotL > fourthSlope)
						{
							NdotL = ((NdotL - fourthSlope) / (thirdSlope - fourthSlope) ) * secondIntensity + (1 - (NdotL - fourthSlope)/ (thirdSlope - fourthSlope)) * thirdIntensity;
						}
						else
						{
							NdotL = thirdIntensity;
						}
					}
				}
			}
			else NdotL = mainIntensity;
			half diff = NdotL;
			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten);
			c.a = s.Alpha;
			return c;
		}


		struct Input {
			float3 pos;
			float depth;
			float3 objPos;
		};
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

		float _Div;

		sampler2D_float _CameraDepthTexture;
		float4 _CameraDepthTexture_TexelSize;

		void vert(inout appdata_full v, out Input OUT)
		{
			UNITY_INITIALIZE_OUTPUT(Input, OUT);
			OUT.pos = v.vertex.xyz;
			OUT.pos = mul(unity_ObjectToWorld, v.vertex).xyz;
			OUT.objPos =  mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz;
			//UNITY_TRANSFER_DEPTH(OUT.depth);
			

			COMPUTE_EYEDEPTH(OUT.depth);
		}

		void surf(Input IN, inout SurfaceOutput o) {
			o.Albedo = _Color;		

			float p = PerlinNormal(IN.pos, _SOctaves, IN.objPos, _SFrequency, _SAmplitude, _SLacunarity, _SPersistence);
			p = clamp(p, 0, 1);


			float h = PerlinNormal(IN.pos, _BOctaves, IN.objPos, _BFrequency, _BAmplitude - (IN.depth / (_Div * 2)), _BLacunarity, _BPersistence + (IN.depth / _Div));
			float noiseColor[3];
			for (int i = 0; i < 3; i++)
			{
				noiseColor[i] = PerlinNormal(IN.pos, _BOctaves, _BOffset + i * 1000, _BFrequency * 2, _BAmplitude, _BLacunarity, _BPersistence / 1.2);
				noiseColor[i] = clamp(noiseColor[i], 0, 1);
			}
			float3 colorVariation;
			colorVariation.r = noiseColor[0];
			colorVariation.g = noiseColor[1];
			colorVariation.b = noiseColor[2];
			
			h = clamp(h, 0, 1);
			float3 col = o.Albedo * 0.2;
			if (h > 0.9) col  = o.Albedo * 0.8 - (col * colorVariation / 2.0f);
			else if (h < (0.8 - (IN.depth / _Div)) && p < 0.75) col = o.Albedo;
			else if (p >= 0.8) col = o.Albedo * 0.5;
			col +=col * (colorVariation / 20.0f);
			o.Albedo = col * (1 - (IN.depth / 200));

		}
		ENDCG
	}
	FallBack "Diffuse"
}
