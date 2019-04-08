Shader "Hidden/DistortionShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
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

				float noise = tex2D(_DistortionTexture, i.uv).r;
				float depth1 = tex2D(_CameraDepth, i.uv + float2(delta.x, delta.y) * 10);
				float depth2 = tex2D(_CameraDepth, i.uv + float2(-delta.x, delta.y) * 10);
				float depth3 = tex2D(_CameraDepth, i.uv + float2(delta.x, -delta.y) * 10);
				float depth4 = tex2D(_CameraDepth, i.uv + float2(-delta.x, -delta.y) * 10);
				//float depth = (depth1 + depth2 + depth3 + depth4) / 4;
				float depth = min(1,min(depth1, min(depth2, min(depth3, depth4))) + 0.2);
				//depth = tex2D(_CameraDepth, i.uv);
				float depthVar = 1.0f;
				float size = 5.0f;

				_Intensity = 10;
				if (_Type == 1)
				{
					depthVar = min(1, (1 - (noise * depth)));
					_Intensity = 5.0f;
					size = 1.0f;
				}

				fixed4 distortion = tex2D(_DistortionTexture, i.uv / size) * 2 - 1;
				fixed4 col = tex2D(_MainTex, float2(i.uv.x + distortion.x * delta.x * _Intensity * depth, i.uv.y + distortion.y * delta.y * _Intensity * depth)) *depthVar;

				//return depth;
				return col;
			}
			ENDCG
		}
	}
}
