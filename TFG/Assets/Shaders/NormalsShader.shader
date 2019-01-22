Shader "Hidden/NormalsShader"
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
		//float4 depthnormal = tex2D(_CameraDepthNormalsTexture, i.uv);

		////decode depthnormal
		//float3 normal;
		//float depth;
		//DecodeDepthNormal(depthnormal, depth, normal);

		////get depth as distance from camera in units 
		//depth = depth * _ProjectionParams.z;

		//return float4(normal, 1);
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