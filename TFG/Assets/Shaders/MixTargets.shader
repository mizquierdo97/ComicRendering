Shader "Hidden/MixTargets"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
		CGINCLUDE

#include "UnityCG.cginc"


		sampler2D _MainTex;
	uniform float4 _MainTex_TexelSize;
	uniform sampler2D _ColorEdges;
	uniform sampler2D _NormalsEdges;
	uniform sampler2D _DepthEdges;


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
		float4 color = tex2D(_ColorEdges, i.uv.xy);
		float4 normals = tex2D(_NormalsEdges, i.uv.xy);
		float4 depth = tex2D(_DepthEdges, i.uv.xy);
		return color;
		return min((color + normals + depth), 1);
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