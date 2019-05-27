// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Custom/PorldPositionShader" {
	Properties{
	  _MainTex("Texture", 2D) = "white" {}
	_Color("Color", Color) = (1,1,1,1)
	}
		SubShader{
		  Tags { "RenderType" = "Opaque" /* "RenderType" = "MKGlow"*/}
		  CGPROGRAM
		  #pragma surface surf WrapLambert vertex:vert

		half4 LightingWrapLambert(SurfaceOutput s, half3 lightDir, half atten) {
		return 0.5;
		}
		  struct Input {
			  float2 uv_MainTex;
			  float3 customColor;
		  };
		  void vert(inout appdata_full v, out Input o) {
			  UNITY_INITIALIZE_OUTPUT(Input,o);
			  o.customColor = mul(unity_ObjectToWorld, v.vertex);
			 
		  }
		  sampler2D _MainTex;
		  void surf(Input IN, inout SurfaceOutput o) {
			  o.Albedo = IN.customColor;
		  }
		  ENDCG
	}


		Fallback "Diffuse"
}