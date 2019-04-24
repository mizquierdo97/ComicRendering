Shader "Hidden/GaussianFilter"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}


		CGINCLUDE

#include "UnityCG.cginc"

	sampler2D _MainTex;
	uniform float4 _MainTex_TexelSize;
	uniform float _Intensity;
	uniform sampler2D_float _CameraDepth;

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

	float normpdf(float x,float y)
	{
		int kernel[5][5] = { { 1,4,7,4,1}, {4,16,26,16,4},{7,26,41,26,7 },{ 4,16,26,16,4 },{ 1,4,7,4,1 } };
		return kernel[x + 2][y + 2];
	}

	half4 blur(sampler2D tex, float2 uv, float blurAmount) {	
		float depth = tex2D(_CameraDepth, uv).r;
		half4 col = tex2D(tex, uv);		

		const int mSize = 5;		

		const int iter = (mSize - 1) / 2;
		int times = 1;
		for (int i = -iter; i <= iter; ++i) {
			for (int j = -iter; j <= iter; ++j) {
				float pixelDepth = (tex2D(_CameraDepth, float2(uv.x + i * blurAmount * _MainTex_TexelSize.x * depth , uv.y + j * blurAmount * _MainTex_TexelSize.y * depth)));
				if (depth < pixelDepth)
				{
					col += (tex2D(tex, float2(uv.x + i * blurAmount * _MainTex_TexelSize.x * depth, uv.y + j * blurAmount * _MainTex_TexelSize.y * depth)));
					times++;
				}
			}
		}
		//return blurred color
		return col / times;
	}

	fixed4 frag(v2f i) : SV_Target
	{
	return blur(_MainTex, i.uv, _Intensity);
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