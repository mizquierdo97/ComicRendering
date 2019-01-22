Shader "Hidden/DoubleThreshHold"
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


	uniform half4 _Color;
	uniform float _SobColWidth;
	uniform float _SobNormWidth;
	uniform float _SobDepthWidth;
	uniform float _MinThreshold;
	uniform float _MaxThreshold;

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


	float threshold(sampler2D tex, float2 uv, float width) {
		float2 delta = float2(width * _MainTex_TexelSize.x, width * _MainTex_TexelSize.y);

		float4 pixel = tex2D(tex, uv);


		if (pixel.x <= _MinThreshold) return 0.0;
		if (pixel.x >= _MaxThreshold) return 1.0;

		return 1.0;

		return 0;
	}

	fixed4 frag(v2f i) : SV_Target
	{

		float a = threshold(_MainTex, i.uv, 1);
	return float4(a, a, a, 1);


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