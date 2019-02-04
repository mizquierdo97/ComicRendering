// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ObjectDepthShader" {
	Properties{
	  _MainTex("Texture", 2D) = "white" {}
	_Color("Color", Color) = (1,1,1,1)
	}
		SubShader{
		  Tags { "RenderType" = "Opaque" }
		  CGPROGRAM
		  #pragma surface surf Lambert vertex:vert
		  struct Input {
			  float2 uv_MainTex;
			  float3 customColor;
		  };
		  void vert(inout appdata_full v, out Input o) {
			  UNITY_INITIALIZE_OUTPUT(Input,o);
			  o.customColor =-mul(UNITY_MATRIX_MV, v.vertex).z *_ProjectionParams.w;
		  }
		  sampler2D _MainTex;
		  void surf(Input IN, inout SurfaceOutput o) {
			  o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			  o.Albedo = IN.customColor;
		  }
		  ENDCG
	}
		Fallback "Diffuse"
}