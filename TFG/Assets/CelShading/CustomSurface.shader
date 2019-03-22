Shader "Custom/CustomSurface" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_Intensity("Intensity", Range(0,1)) = 1.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

			CGPROGRAM
#pragma surface surf WrapLambert

			half4 LightingWrapLambert(SurfaceOutput s, half3 lightDir, half atten) {
			half NdotL = dot(s.Normal, lightDir);	
			float firstSlope = 0.5;
			float secondSlope = 0.4;
			float thirdSlope = -0.5;
			float fourthSlope = -0.6;

			float mainIntensity = 1.0f;
			float secondIntensity = 1;
			float thirdIntensity = 0.8;
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



				/*if (NdotL <= 0)
				{
					if (NdotL < -0.3)
					{
						if (NdotL < -0.5)
						{
							NdotL = 0.0f;
						}
						else
						{
							NdotL = (NdotL + 0.5) * (0.3 / 0.2);
						}
					}
					else
					{
						NdotL = 0.5;
					}
				}*/

			}
			else NdotL = mainIntensity;
			half diff = NdotL;
			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten);
			c.a = s.Alpha;
			return c;
		}

		struct Input {
			float2 uv_MainTex;
		};
		float4 _Color;
		sampler2D _MainTex;
		void surf(Input IN, inout SurfaceOutput o) {
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Color;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
