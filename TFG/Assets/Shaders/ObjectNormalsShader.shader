// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/ObjectNormalShader" {
	Properties{
	  _MainTex("Texture", 2D) = "white" {}
	_Color("Color", Color) = (1,1,1,1)
			_Intensity("Intensity", float) = 1
	}
		SubShader{
		  Tags { "RenderType" = "Opaque" }
		  CGPROGRAM
		  #pragma surface surf Lambert vertex:vert
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

		  void vert(inout appdata_full v, out Input o) {
			  UNITY_INITIALIZE_OUTPUT(Input, o);
			  const float PI = 3.14159;
			  float3 norm = (UnityObjectToWorldNormal(v.normal));
			  float3 pos = mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz;
			  //o.customColor = float3(sin(pos.x*5 + pos.y*2 + pos.z), cos(pos.x - pos.y*20 + pos.z*3), cos(pos.x*4 - pos.y*5 - pos.z*2));
			  //o.customColor = float3(
				 // sin(/*(pos.x * 5 + pos.y * 2 + pos.z) *	*/	/**/	(norm.x * 0.5 + /*norm.y * 0.7 +*/ norm.z * 0.2)),
				 // sin(/*(pos.x - pos.y * 20 + pos.z * 3) **/		/**/	(/*norm.x * 1 -*/ norm.y * 0.2 - norm.z * 0.1)),
				 // sin(/*(pos.x * 4 - pos.y * 5 - pos.z * 2) **/	/**/	(norm.x * 0.5  - norm.y * 0.4 /*+ norm.z * 1*/)));

			  //o.customColor = float3(
				 // norm.x * abs(sin(pos.x * 5 + pos.y * 2 + pos.z)) + norm.y * abs(sin(pos.x * 5 + pos.y * 2 + pos.z)) + norm.z * abs(sin(pos.x * 5 + pos.y * 2 + pos.z)),
				 // norm.x * abs(sin(pos.x * 1 + pos.y * 1 + pos.z *2)) + norm.y * abs(sin(pos.x * 1 + pos.y * 1 + pos.z)) + norm.z * abs(sin(pos.x * 1 + pos.y * 1 + pos.z*2)),
				 // norm.x * abs(sin(pos.x * 3 + pos.y * 5 + pos.z * 3)) + norm.y * abs(sin(pos.x * 3 + pos.y * 5 + pos.z * 4)) + norm.z * abs(sin(pos.x * 2 + pos.y * 3 + pos.z * 4)));

			  //o.customColor = (o.customColor);

			  float r = cos(pos.x + pos.y + pos.z);
			  float g = sin(pos.x + pos.y + pos.z);
			  float b = cos(pos.x + pos.y + pos.z);

			  float A = pos.x;
			  float B = pos.y;
			  float C = pos.z;
			  float3x3 mat = {
				  cos(B) * cos(C),-cos(B) * sin(C) * cos(A) + sin(B) * sin(A), cos(B) * sin(C) * sin(A) + sin(B) * cos(A),
				  sin(C),cos(C) * cos(A),-cos(C) * sin(A),
				  sin(B)*cos(C),sin(B) * sin(C) * cos(A) + cos(B) * sin(A),-sin(B) * sin(C) * sin(A) + cos(B) * cos(A)

			  };


			  float xR = cos(cos(norm.x) + cos(pos.x * 2 * PI )) * 2;
			  float xG = cos(pos.y * 2 * PI + (2 * PI) / 3/* + pos.x*/) * 0;
			  float xB = cos((pos.z * 2 * PI) + (2*(2 * PI))/3/* + pos.x*/) * 0;

			  float yR = cos(norm.y* 2 * PI) * 2;
			  float yG = cos(norm.y * 2 * PI + (2 * PI) / 3/* + pos.x*/) * 2;
			  float yB = cos((norm.y * 2 * PI) + (2 * (2 * PI)) / 3/* + pos.x*/) * 2;

			  float zR = cos(norm.z * 2 * PI) * 2;
			  float zG = cos(norm.z * 2 * PI + (2 * PI) / 3/* + pos.x*/) * 2;
			  float zB = cos((norm.z * 2 * PI) + (2 * (2 * PI)) / 3/* + pos.x*/) * 2;

			  //float3 RGB = clamp(float3(R, G, B),0,1);

			  float3 xRGB = clamp(float3(xR, xG, xB), 0, 1);
			  float3 yRGB = clamp(float3(yR, yG, yB), 0, 1);
			  float3 zRGB = clamp(float3(zR, zG, zB), 0, 1);

			  ////norm = clamp(norm + RGB, 0, 1);



			  o.customColor = lerp(abs(mul(mat, v.normal)), sin(pos)*0.5 + 0.5, _Intensity);
			  //o.customColor = v.normal + normalize((pos) % 1);
			  //o.customColor = sin(pos)*0.5 + 0.5;
		  }
		  sampler2D _MainTex;
		  void surf(Input IN, inout SurfaceOutput o) {

			  o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			  o.Albedo = IN.customColor;
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