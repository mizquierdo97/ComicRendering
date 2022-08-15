
Shader "Custom/ObjectNormalShader" {
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
					fixed4 c;
		c.rgb = s.Albedo;
		c.a = 1;
		return c;
		}
		  struct Input {
			  float2 uv_MainTex;
			  float3 customColor;
		  };

	sampler2D _CameraDepthNormalsTexture;
	uniform float _Intensity;
	fixed4 LightingNoLighting(SurfaceOutput s, fixed3 lightDir, fixed atten) {
		
		fixed4 c;
		c.rgb = s.Albedo;
		c.a = 1;

		return 0;
	}

		  void vert(inout appdata_full v, out Input o) {
			  UNITY_INITIALIZE_OUTPUT(Input, o);
			  const float PI = 3.14159;
			  float3 norm = (UnityObjectToWorldNormal(v.normal));
			  float3 pos = mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz;
			 
			  float r = cos(pos.x + pos.y + pos.z);
			  float g = sin(pos.x + pos.y + pos.z);
			  float b = cos(pos.x + pos.y + pos.z);

			  float A = pos.x + pos.y + pos.z;
			  float B = 3* A;
			  float C = 5 * A;
			  float3x3 mat = {
				  cos(B) * cos(C),-cos(B) * sin(C) * cos(A) + sin(B) * sin(A), cos(B) * sin(C) * sin(A) + sin(B) * cos(A),
				  sin(C),cos(C) * cos(A),-cos(C) * sin(A),
				  sin(B)*cos(C),sin(B) * sin(C) * cos(A) + cos(B) * sin(A),-sin(B) * sin(C) * sin(A) + cos(B) * cos(A)

			  };


			  o.customColor = lerp(abs(mul(mat, v.normal)), float3(sin(A), sin(B), sin(C))*0.5 + 0.5, _Intensity);
			  //o.customColor = v.normal + normalize((pos) % 1);
			  //o.customColor = sin(pos)*0.5 + 0.5;
		  }
		  sampler2D _MainTex;
		  void surf(Input IN, inout SurfaceOutput o) {

			  o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			  o.Albedo = IN.customColor * 2;
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