Shader "Hidden/FinalShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}

		CGINCLUDE

#include "UnityCG.cginc"


		sampler2D _MainTex;
	uniform float4 _MainTex_TexelSize;

	sampler2D _CameraDepthNormalsTexture;
	uniform sampler2D_float _CameraDepthTexture;
	uniform sampler2D_float _CameraDepth;

	uniform half4 _OutlineColor;
	uniform float _SobColWidth;
	uniform float _SobNormWidth;
	uniform float _SobDepthWidth;
	uniform sampler2D _OutlineTex;

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

	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.uv;
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		float2 texel = _MainTex_TexelSize * 5;
		float depth = 1- tex2D(_CameraDepth, i.uv).r;
		depth = max(depth, 1 - tex2D(_CameraDepth, i.uv + (1,0) * texel).r); 
		depth = max(depth, 1 - tex2D(_CameraDepth, i.uv + (-1, 0) * texel).r);
		depth = max(depth, 1 - tex2D(_CameraDepth, i.uv + (0, 1) * texel).r);
		depth = max(depth, 1 - tex2D(_CameraDepth, i.uv + (0, -1) * texel).r);

		return lerp(tex2D(_MainTex, i.uv.xy), _OutlineColor, tex2D(_OutlineTex, i.uv.xy) * _OutlineColor.a);
	}
		ENDCG


		SubShader
	{
		Pass{
			//Cull Off ZWrite Off ZTest Always

			ZTest Always Cull Off ZWrite Off


			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
			ENDCG
		}

	}
}