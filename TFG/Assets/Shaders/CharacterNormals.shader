Shader "Hidden/CharacterNormalsShader"
{

Properties{
	  _MainTex("Texture", 2D) = "white" {}
	_Color("Color", Color) = (1,1,1,1)
			_Intensity("Intensity", float) = 1
}
SubShader{
  Tags { "RenderType" = "Opaque" }
  CGPROGRAM
  #pragma surface surf WrapLambert vertex:vert

half4 LightingWrapLambert(SurfaceOutput s, half3 lightDir, half atten) {
	return 0;
}
  struct Input {
	  float2 uvs;
	  float3 vertex;
  };

sampler2D _CameraDepthNormalsTexture;


	  void vert(inout appdata_full v, out Input o) {		  
		  o.vertex = normalize(mul((float3x3)UNITY_MATRIX_MV, v.normal)) ; // (UnityObjectToWorldNormal(v.normal));
		  //o.vertex.g = 0;
		  //o.vertex.r = 0;
		  o.uvs = v.texcoord;
	  }
	  sampler2D _MainTex;
	  void surf(Input IN, inout SurfaceOutput o) {

		  float4 normTex = tex2D(_CameraDepthNormalsTexture, IN.uvs);
		  float3 normals;

		  normals.r = normTex.r;
		  normals.g = normTex.g;
		  normals.b = normTex.b;

		  float4 ret = float4(normals.r, normals.g, normals.b, 1);
		  o.Albedo = IN.vertex/2;
	  }
	  ENDCG
	}

		SubShader{
		  Tags { "RenderType" = "Transparent" }
		  CGPROGRAM
		  #pragma surface surf Lambert vertex:vert
		  struct Input {
			  float2 uv_MainTex;
			  float3 customColor;
		  };

		  void vert(inout appdata_full v, out Input o) {

			  UNITY_INITIALIZE_OUTPUT(Input,o);
			  float3 baseWorldPos = mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz;
			  o.customColor = normalize((baseWorldPos) % 1);

		  }
		  sampler2D _MainTex;
		  void surf(Input IN, inout SurfaceOutput o) {

			  o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			  o.Albedo = IN.customColor;
		  }
		  ENDCG
	  }
}