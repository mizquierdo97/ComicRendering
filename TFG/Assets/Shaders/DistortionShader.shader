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


			fixed _SOctaves;
			float _SFrequency;
			float _SAmplitude;
			float3 _SOffset;
			float _SLacunarity;
			float _SPersistence;
			uniform float4 _MainTex_TexelSize;

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

				float3 noise = tex2D(_DistortionTexture, i.uv);
				float depth1 = tex2D(_CameraDepth, i.uv + float2(delta.x, delta.y) );
				float depth2 = tex2D(_CameraDepth, i.uv + float2(-delta.x, delta.y));
				float depth3 = tex2D(_CameraDepth, i.uv + float2(delta.x, -delta.y) );
				float depth4 = tex2D(_CameraDepth, i.uv + float2(-delta.x, -delta.y));
				//float depth = (depth1 + depth2 + depth3 + depth4) / 4;
				float depth = min(depth1, min(depth2, min(depth3, depth4)));// min(1, min(depth1, min(depth2, min(depth3, depth4))) + 0.2);
				//depth = tex2D(_CameraDepth, i.uv);
				float size = 5.0f;

				float minAmplitude = 0.0f;
				
				if (noise.x <= 0.5f && noise.x >= -0.5f)
				{
					noise.x = i.uv.x * 10;
					noise.y = i.uv.y * 10;
					noise.z = i.uv.y * 10;
					minAmplitude = 0.0f;
				}
				
				float smallNoiseX = PerlinNormal(noise, _SOctaves, float3(0,0,0), _SFrequency, _SAmplitude * max(minAmplitude, (1 - depth * 1.7)), _SLacunarity, _SPersistence);
				smallNoiseX = smallNoiseX * 0.5 + 0.5;
				float smallNoiseY = PerlinNormal(noise, _SOctaves, float3(10000, 10000, 0), _SFrequency, _SAmplitude * max(minAmplitude,(1 - depth * 1.7)), _SLacunarity, _SPersistence);
				smallNoiseY = smallNoiseY * 0.5 + 0.5;

				_Intensity = 10;
				float multiply = 1.0;
				if (_Type == 1)
				{
					_Intensity = 10.0f;
					size = 1.0f;
					multiply = clamp((smallNoiseX * 1.5), 0.5f, 1.0f);
				}

				float distortionX = clamp(smallNoiseX, -1, 1);
				float distortionY = clamp(smallNoiseY, -1, 1);
				fixed4 col = tex2D(_MainTex, float2(i.uv.x + distortionX * delta.x * _Intensity * depth, i.uv.y + distortionY * delta.y * _Intensity * depth));
				col *= multiply;

				//return depth;
				float3 ret = distortionX;
				return col;// float4(ret, 1);// float4(noise, 1);
			}
			ENDCG
		}
	}
}
