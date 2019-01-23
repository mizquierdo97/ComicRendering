Shader "Hidden/SobelShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}

		CGINCLUDE

#include "UnityCG.cginc"


	sampler2D _MainTex;
	int _SobelType;
	uniform float4 _MainTex_TexelSize;

	sampler2D _CameraDepthNormalsTexture;
	uniform sampler2D_float _CameraDepthTexture;
	uniform sampler2D_float _CameraDepth;
	uniform sampler2D_float _CameraNormals;


	uniform half4 _Color;
	uniform float _ColorWidth;
	uniform float _NormalWidth;
	uniform float _DepthWidth;
	uniform float _ColThreshold;
	uniform float _NormThreshold;
	uniform float _DepthThreshold;
	uniform float _DistanceFalloff;

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


	float4 sobel(sampler2D tex, float2 uv, float width, bool _fallof) {
		float depth =  1 - tex2D(_CameraDepth, uv);
		float2 texel = _MainTex_TexelSize;
		float falloff = _DistanceFalloff;
		if (!_fallof) falloff = 0;
		float2 delta = float2(width * texel.x * pow(depth, falloff), width * texel.y *  pow(depth, falloff));

		float3 hr =  float3(0, 0, 0);
		float3 vt = float3(0, 0, 0);
		int size = 3;
		int it = (size - 1) / 2;
		int temp = it;
		for (int i = -it; i <= it; i++)
		{			
			for (int n = -it; n <= it; n++)
			{
				int mult = 1;
				int mult2 = 1;
				if (i > 0) mult2 = -1;
				if (i == 0) mult = 0;
				hr += tex2D(tex, (uv + float2(i, n) * delta)) * mult * mult2 * (abs(i) + (it - abs(n)));

			}
		}
		//hr += tex2D(tex, (uv + float2(-1.0, -1.0) * delta)) *	 1.0;
		//hr += tex2D(tex, (uv + float2(0.0, -1.0) * delta)) *	 0.0;
		//hr += tex2D(tex, (uv + float2(1.0, -1.0) * delta)) *	-1.0;
		//hr += tex2D(tex, (uv + float2(-1.0, 0.0) * delta)) *	 2.0;
		//hr += tex2D(tex, (uv + float2(0.0, 0.0) * delta)) *		 0.0;
		//hr += tex2D(tex, (uv + float2(1.0, 0.0) * delta)) *		-2.0;
		//hr += tex2D(tex, (uv + float2(-1.0, 1.0) * delta)) *	 1.0;
		//hr += tex2D(tex, (uv + float2(0.0, 1.0) * delta)) *		 0.0;
		//hr += tex2D(tex, (uv + float2(1.0, 1.0) * delta)) *		-1.0;

		for (int i = -it; i <= it; i++)
		{
			for (int n = -it; n <= it; n++)
			{
				int mult = 1;
				int mult2 = 1;
				if (n > 0) mult2 = -1;
				if (n == 0) mult = 0;
				vt += tex2D(tex, (uv + float2(i, n) * delta)) * mult * mult2 * (abs(n) + (it - abs(i)));

			}
		}
		//vt += tex2D(tex, (uv + float2(-1.0, -1.0) * delta)) *	 1.0;
		//vt += tex2D(tex, (uv + float2(0.0, -1.0) * delta)) *	 2.0;
		//vt += tex2D(tex, (uv + float2(1.0, -1.0) * delta)) *	 1.0;
		//vt += tex2D(tex, (uv + float2(-1.0, 0.0) * delta)) *	 0.0;
		//vt += tex2D(tex, (uv + float2(0.0, 0.0) * delta)) *		 0.0;
		//vt += tex2D(tex, (uv + float2(1.0, 0.0) * delta)) *		 0.0;
		//vt += tex2D(tex, (uv + float2(-1.0, 1.0) * delta)) *	-1.0;
		//vt += tex2D(tex, (uv + float2(0.0, 1.0) * delta)) *		-2.0;
		//vt += tex2D(tex, (uv + float2(1.0, 1.0) * delta)) *		-1.0;


		
		float4 ret = 0.0;
		float intensityR = sqrt(hr.x*hr.x + vt.x * vt.x);
		float intensityG = sqrt(hr.y*hr.y + vt.y * vt.y);
		float intensityB = sqrt(hr.z*hr.z + vt.z * vt.z);
		
		ret = (intensityR + intensityG + intensityB);		
		return ret;

	}

	float4 sobelDepth(sampler2D tex, float2 uv, float width) {
		float depth = tex2D(tex, uv);
		float2 delta = float2(width * _MainTex_TexelSize.x , width * _MainTex_TexelSize.y );

		float hr = 0.0;
		float vt = 0.0;
		float pixel = (tex2D(tex, uv).r);
		hr +=(tex2D(tex, (uv + float2(-1.0, -1.0) * delta)).r) * 1.0;
		hr +=(tex2D(tex, (uv + float2(0.0, -1.0) * delta)).r) *	 0.0;
		hr +=(tex2D(tex, (uv + float2(1.0, -1.0) * delta)).r) *	-1.0;
		hr +=(tex2D(tex, (uv + float2(-1.0, 0.0) * delta)).r) *	 2.0;
		hr +=(tex2D(tex, (uv + float2(0.0, 0.0) * delta)).r) *	 0.0;
		hr +=(tex2D(tex, (uv + float2(1.0, 0.0) * delta)).r) *	-2.0;
		hr +=(tex2D(tex, (uv + float2(-1.0, 1.0) * delta)).r) *	 1.0;
		hr +=(tex2D(tex, (uv + float2(0.0, 1.0) * delta)).r) *	 0.0;
		hr +=(tex2D(tex, (uv + float2(1.0, 1.0) * delta)).r) *	-1.0;

		vt +=(tex2D(tex, (uv + float2(-1.0, -1.0) * delta)).r) * 1.0;
		vt +=(tex2D(tex, (uv + float2(0.0, -1.0) * delta)).r) *	 2.0;
		vt +=(tex2D(tex, (uv + float2(1.0, -1.0) * delta)).r) *	 1.0;
		vt +=(tex2D(tex, (uv + float2(-1.0, 0.0) * delta)).r) *	 0.0;
		vt +=(tex2D(tex, (uv + float2(0.0, 0.0) * delta)).r) *	 0.0;
		vt +=(tex2D(tex, (uv + float2(1.0, 0.0) * delta)).r) *	 0.0;
		vt +=(tex2D(tex, (uv + float2(-1.0, 1.0) * delta)).r) *	-1.0;
		vt +=(tex2D(tex, (uv + float2(0.0, 1.0) * delta)).r) *	-2.0;
		vt +=(tex2D(tex, (uv + float2(1.0, 1.0) * delta)).r) *	-1.0;

		float ret = depth - (tex2D(tex, (uv + float2(1.0, 0.0) * delta)).r);
		ret += depth - (tex2D(tex, (uv + float2(-1.0, 0.0) * delta)).r);
		ret += depth - (tex2D(tex, (uv + float2(0.0, 1.0) * delta)).r);
		ret += depth - (tex2D(tex, (uv + float2(0.0, -1.0) * delta)).r);
		ret = 1 - ret;
		ret = min(ret,1);
		//ret = max(ret, 0);
		ret = 1 - ret;

		/*float ret = 0.0;
		float intensityR = sqrt(hr*hr + vt * vt);	
		ret = intensityR;*/
		return ret;
	}


	fixed4 frag(v2f i) : SV_Target
	{
		float4 final;
		float4 colSobel = sobel(_MainTex, i.uv, _ColorWidth, false);
		float4 normSobel = sobel(_CameraNormals, i.uv, _NormalWidth, true);
		float4 depthSobel = sobelDepth(_CameraDepth, UNITY_PROJ_COORD(i.uv), _DepthWidth);		
		float depth = tex2D(_CameraDepth, i.uv).x;
		
		if (colSobel.x < _ColThreshold )
			colSobel = 0;
		else
			colSobel = 1;

		if (normSobel.x < _NormThreshold)
			normSobel = 0;
		else 
			normSobel = 1;

		if (depthSobel.x < _DepthThreshold)
			depthSobel = 0;
		else 
			depthSobel = 1;

		return min(colSobel + normSobel + depthSobel , 1);

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