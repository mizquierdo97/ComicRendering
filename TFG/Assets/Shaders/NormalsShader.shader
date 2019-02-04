﻿Shader "Hidden/NormalsShader"
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
		//return tex2D(_MapNormals, i.uv);
	float characterDepth = tex2D(_CharacterDepth, i.uv).r;
	float mapDepth = tex2D(_MapDepth, i.uv).r;

	if (mapDepth < characterDepth)
	{
		return tex2D(_MapNormals, i.uv);
	}
	else
	{
		return tex2D(_CharactersNormals, i.uv);
	}
		float4 normTex = tex2D(_CameraDepthNormalsTexture, i.uv);
		float depth = tex2D(_CameraDepth, i.uv).x;
		float3 normals;

		normals.r = normTex.r;
		normals.g = normTex.g;
		normals.b = normTex.b;
	
		float4 ret = float4(normals.r, normals.g, normals.b, 1);
		return ret;
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