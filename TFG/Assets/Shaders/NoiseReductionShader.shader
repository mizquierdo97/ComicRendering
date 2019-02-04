Shader "Hidden/NoiseReductionShader"
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
	uniform int _UsingDepth;
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

	#define s2(a, b)                            temp = a; a = min(a, b); b = max(temp, b);
	#define t2(a, b)                            s2(arr[a], arr[b]);
	#define t24(a, b, c, d, e, f, g, h)         t2(a, b); t2(c, d); t2(e, f); t2(g, h);
	#define t25(a, b, c, d, e, f, g, h, i, j)   t24(a, b, c, d, e, f, g, h); t2(i, j);

	half4 noiseReduction(sampler2D tex, float2 uv) {
				float depth = 0;
				//depth = pow(depth, 1);

				if (_UsingDepth == 0)
				{
					depth = tex2D(_CameraDepth, uv).r ;
					depth = pow(depth, 1) * 10;
					//depth = max(depth, 0);
				}

				if (_UsingDepth == 1)
				{
					depth = tex2D(_CameraDepth, uv).r;		
					return  tex2D(tex, (uv));
				}
				
				half4 col = tex2D(tex, uv);
				const int mSize = 5;
		
				const int iter = (mSize - 1) / 2;
		
				int onesCount = 0;
				int zeroCount = 0;
				float4 arr[mSize * mSize];
				for (int i = -iter; i <= iter; ++i) {
					for (int j = -iter; j <= iter; ++j) {
						arr[(i + iter) * mSize + (j + iter)] = tex2D(tex, (uv + float2(i * _MainTex_TexelSize.x * depth, j * _MainTex_TexelSize.y * depth)));
					}
				}

				float4 temp;

				t25(0, 1, 3, 4, 2, 4, 2, 3, 6, 7);
				t25(5, 7, 5, 6, 9, 7, 1, 7, 1, 4);
				t25(12, 13, 11, 13, 11, 12, 15, 16, 14, 16);
				t25(14, 15, 18, 19, 17, 19, 17, 18, 21, 22);
				t25(20, 22, 20, 21, 23, 24, 2, 5, 3, 6);
				t25(0, 6, 0, 3, 4, 7, 1, 7, 1, 4);
				t25(11, 14, 8, 14, 8, 11, 12, 15, 9, 15);
				t25(9, 12, 13, 16, 10, 16, 10, 13, 20, 23);
				t25(17, 23, 17, 20, 21, 24, 18, 24, 18, 21);
				t25(19, 22, 8, 17, 9, 18, 0, 18, 0, 9);
				t25(10, 19, 1, 19, 1, 10, 11, 20, 2, 20);
				t25(2, 11, 12, 21, 3, 21, 3, 12, 13, 22);
				t25(4, 22, 4, 13, 14, 23, 5, 23, 5, 14);
				t25(15, 24, 6, 24, 6, 15, 7, 16, 7, 19);
				t25(3, 11, 5, 17, 11, 17, 9, 17, 4, 10);
				t25(6, 12, 7, 14, 4, 6, 4, 7, 12, 14);
				t25(10, 14, 6, 7, 10, 12, 6, 10, 6, 17);
				t25(12, 17, 7, 17, 7, 10, 12, 18, 7, 12);
				t24(10, 18, 12, 20, 10, 20, 10, 12);

				return arr[_Time.x];
				return arr[((mSize * mSize)-1)/2];
				if (onesCount >= zeroCount)
					return col;
				else
					return 0;
				return col;
			}
		
			fixed4 frag(v2f i) : SV_Target
			{
				return noiseReduction(_MainTex, i.uv);
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