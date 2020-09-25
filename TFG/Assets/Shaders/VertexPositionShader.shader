// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Custom/VertexPositionShader" {
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
			  float2 uv_MainTex;
			  float3 customColor;
		  };

	sampler2D _CameraDepthNormalsTexture;
	uniform float _Intensity;
	fixed4 LightingNoLighting(SurfaceOutput s, fixed3 lightDir, fixed atten) {

		fixed4 c;
		c.rgb = s.Albedo;
		c.a = 1;

		return c;
	}
	half3 ObjectScale() {
		return half3(
			length(unity_ObjectToWorld._m00_m10_m20),
			length(unity_ObjectToWorld._m01_m11_m21),
			length(unity_ObjectToWorld._m02_m12_m22)
			);
	}
		  void vert(inout appdata_full v, out Input o) {
			  UNITY_INITIALIZE_OUTPUT(Input, o);
			  float3 viewN = normalize(mul(UNITY_MATRIX_IT_MV, v.normal.xyzz).xyz);
			  o.customColor = v.vertex;// float3(abs(X), 0, 0);
			  //o.customColor = v.normal + normalize((pos) % 1);
			  //o.customColor = sin(pos)*0.5 + 0.5;
		  }
		  sampler2D _MainTex;
		  void surf(Input IN, inout SurfaceOutput o) {

			  o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			  o.Albedo = IN.customColor * ObjectScale();
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