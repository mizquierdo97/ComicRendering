// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/ObjectNormalShader" {
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
			  float3 baseWorldPos = mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz;
			  o.customColor =  v.normal + normalize((baseWorldPos) % 1);

		  }
		  sampler2D _MainTex;
		  void surf(Input IN, inout SurfaceOutput o) {

			  o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			  o.Albedo = IN.customColor;
		  }
		  ENDCG
	}	
}