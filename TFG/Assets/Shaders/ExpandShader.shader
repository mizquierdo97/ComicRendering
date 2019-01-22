Shader "Hidden/ExpandShader"
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
	uniform int _Iterations;


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


	float expand(sampler2D tex, float2 uv, float width) {
		float2 delta = float2(width * _MainTex_TexelSize.x, width * _MainTex_TexelSize.y);
		float pixel = tex2D(tex, uv).x;
		int size = _Iterations;
		int it = (size - 1);
		float actual = 0.0;
		float dist = 0.0f;
		int count = 0;
		for (int i = -it; i < it; i++)
		{
			for (int j = -it; j < it; j++)
			{
				if (i == 0 && j == 0) continue;
				float test = tex2D(tex, (uv + float2(i, j) * delta)).x;
				if (test > pixel)
				{
					dist = sqrt(i*i + j * j);
					//_max = test;
					count++;
				}
			}
		}

		if (count >= 1)
			return 1;
		return pixel;

	}

	float threshold(float pixel) {

		if (pixel <= 0.2) return 0.0;
		return 1;
	}


	fixed4 frag(v2f i) : SV_Target
	{
		
		float a = expand(_MainTex, i.uv, 1);
	

	//float ret = tex2D(_MainTex, i.uv);
	float b = pow(a, 1);
	float ret = b;

	return float4(ret, ret, ret, 1);


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