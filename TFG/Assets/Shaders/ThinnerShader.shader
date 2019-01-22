Shader "Hidden/ThinnerShader"
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
	uniform int _Iterations;
	uniform float _MinThreshold;
	
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


	float thinn(sampler2D tex, float2 uv, float width) {
		float2 delta = float2(width * _MainTex_TexelSize.x, width * _MainTex_TexelSize.y);
		float4 pixel = tex2D(tex, uv);
		return pixel;
		int size = 11;
		int it = (size - 1) / 2;
		float actual = pixel.x;
		float dist = 0.0f;
		int count = 0;
		for (int i = -it; i <= it; i++)
		{
			for (int j = -it; j <= it; j++)
			{
				if (i == 0 && j == 0) continue;
				float test = tex2D(tex, (uv + float2(i, j) * delta)).x;
				if (test < actual)
				{					
					count++;
				}
			}
		}
		if (count > 0)
			return 1;
	
		return  0;		
		return 0;
	}

	fixed4 frag(v2f i) : SV_Target
	{		
		
	float a = thinn(_MainTex, i.uv, 1);
	//return float4(a, a, a, 1);

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