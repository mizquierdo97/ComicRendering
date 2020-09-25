// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Hidden/BrushShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_SOctaves("Small Noise Octaves", Float) = 9.6
		_SFrequency("Small Noise Frequency", Float) = 1.0
		_SAmplitude("Small Noise Amplitude", Float) = 1.0
		_SLacunarity("Small Noise Lacunarity", Float) = 1.92
		_SPersistence("Small Noise Persistence", Float) = 0.8
		_Div("DepthInstensity", Float) = 1.0
	}

		CGINCLUDE


	//

	ENDCG

	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			sampler2D _CameraDepth;
			sampler2D _BrushTex; 
			sampler2D _VertexPosTex;
			sampler2D _OrientationTex;
			int _Type;
			float _Intensity;


			fixed _SOctaves;
			float _SFrequency;
			float _SAmplitude;
			float3 _SOffset;
			float _SLacunarity;
			float _SPersistence;
			uniform float4 _MainTex_TexelSize;

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



			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;

			fixed4 frag(v2f i) : SV_Target
			{

				if (length(tex2D(_VertexPosTex, i.uv).rgb) == 0.0f)
				return float4(1,1,1,1);
				float3 vertexPos = tex2D(_VertexPosTex, i.uv);
				float3 orientation = tex2D(_OrientationTex, i.uv);
				float2 uv = float2( (vertexPos.x + vertexPos.z/* + vertexPos.z * clamp(orientation.z, 0, 1)*/), (vertexPos.y + vertexPos.z/* + vertexPos.z * clamp(orientation.y, 0, 1)*/) ) * 0.4;
				float4 ret = lerp(float4(1, 1, 1, 1), tex2D(_MainTex,i.uv), pow(tex2D(_BrushTex, lerp(i.uv * 10, uv + float2(10.5,0), 1)),3));
				return ret;// float4(vertexPos.r, vertexPos.g, vertexPos.b, 1);// float4(ret, 1);// float4(noise, 1);
			}
			ENDCG
		}
	}
}
