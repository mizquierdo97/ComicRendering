Shader "Hidden/NormalsShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}
		CGINCLUDE
#include "UnityCG.cginc"


		sampler2D _MainTex;
	uniform float4 _MainTex_TexelSize;

	sampler2D _CameraDepthNormalsTexture;
	uniform sampler2D_float _CameraDepthTexture;
	uniform sampler2D _CameraDepth;
	uniform sampler2D _CharactersNormals;
	uniform sampler2D _MapNormals;
	uniform sampler2D _CharacterDepth;
	uniform sampler2D _MapDepth;

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
	float characterDepth = tex2D(_CharacterDepth, i.uv).r;
	float mapDepth = tex2D(_MapDepth, i.uv).r;
	if (mapDepth > characterDepth)
	{
		return tex2D(_MapNormals, i.uv);
	}
	else
	{
		return tex2D(_CharactersNormals, i.uv);
	}
	}
		ENDCG


		SubShader
	{
		Pass{
			ZTest Always Cull Off ZWrite Off


			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
			ENDCG
		}

	}
}