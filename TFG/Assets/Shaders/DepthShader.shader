Shader "Hidden/DepthShader"
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
		float depthValue = Linear01Depth(tex2D(_CameraDepthTexture, UNITY_PROJ_COORD(i.uv)).r);
	half4 depth = tex2D(_CameraDepthNormalsTexture, UNITY_PROJ_COORD(i.uv));

	depth.r = depthValue;
	depth.g = depthValue;
	depth.b = depthValue;

	depth.a = 1;
	return depth;

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