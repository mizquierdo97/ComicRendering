// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Part of the Shader was created by Alastair Aitchison (url: https://alastaira.wordpress.com)
// Some parts come from https://en.wikibooks.org/wiki/Cg_Programming/Unity/Lighting_Textured_Surfaces
// Some parts come from https://en.wikibooks.org/wiki/Cg_Programming/Unity/Transparency

Shader "Custom/PerspectiveView" {
	Properties{
		[Header(Material)]
		  _MainTex("Texture For Diffuse Material Color", 2D) = "white" {}
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		  _SpecColor("Specular Material Color", Color) = (1,1,1,1)
		  _Shininess("Shininess", Float) = 10
	}

		SubShader{
			Tags {"LightMode" = "ForwardBase"}
			  Tags {"Queue" = "Transparent"}

			Pass{
				 Blend SrcAlpha OneMinusSrcAlpha // use alpha blending

				CGPROGRAM

			// Pragmas
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc" 
			uniform fixed4 _LightColor0;

		// User defined variables
		uniform sampler2D _MainTex;
		uniform fixed4 _Color;
		uniform fixed4 _SpecColor;
		uniform half _Shininess;

		struct VertexInput {
			float4 vertex : POSITION;

			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
		};

		struct VertexOutput {
			float4 pos : SV_POSITION;

			float4 tex : TEXCOORD0;
			fixed3 diffuseColor : TEXCOORD1;
			fixed3 specularColor : TEXCOORD2;
		};

		VertexOutput vert(VertexInput v) {
			VertexOutput o;

			// Perspective Section
			//-------------------------------------------------------------------
			//

			float4 vv = mul(unity_ObjectToWorld, v.vertex);

			// Now adjust the coordinates to be relative to the camera position
			vv.xyz += _WorldSpaceCameraPos.xyz;

			if (vv.y > 0)
				vv.y = vv.z - _WorldSpaceCameraPos.z;
			else
				vv.y = _WorldSpaceCameraPos.z - vv.z - 2;

			if (vv.x > 0)
				vv.x = vv.z - _WorldSpaceCameraPos.z;
			else
				vv.x = _WorldSpaceCameraPos.z - vv.z - 2;

			/*if(vv.z > _WorldSpaceCameraPos.z)
				vv = float4(vv.x - _WorldSpaceCameraPos.x, vv.y - _WorldSpaceCameraPos.y, 0.0f, 0.0f);
			else
				vv = float4(0.0f, 0.0f, 0.0f, 0.0f);*/

				// Now apply the offset back to the vertices in model space
			v.vertex = mul(unity_WorldToObject, vv);

			o.pos = UnityObjectToClipPos(v.vertex);

				// Light Section
				//-------------------------------------------------------------------
				//

				// multiplication with unity_Scale.w is unnecessary 
				// because we normalize transformed vectors

				float3 normalDirection = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				float3 viewDirection = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex).xyz);
				float3 lightDirection;
				float attenuation;

				if (0.0 == _WorldSpaceLightPos0.w) // directional light?
				{
				   attenuation = 1.0; // no attenuation
				   lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				}
				else // point or spot light
				{
				   float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - mul(unity_ObjectToWorld, v.vertex).xyz;
				   float distance = length(vertexToLightSource);
				   attenuation = 1.0 / distance; // linear attenuation 
				   lightDirection = normalize(vertexToLightSource);
				}

				float3 ambientLighting = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;

				float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDirection, lightDirection));

				float3 specularReflection;

				if (dot(normalDirection, lightDirection) < 0.0)
					// light source on the wrong side?
				 {
					specularReflection = float3(0.0, 0.0, 0.0);
					// no specular reflection
			  }
			  else // light source on the right side
			  {
				 specularReflection = attenuation * _LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
			  }

			  o.diffuseColor = ambientLighting + diffuseReflection;
			  o.specularColor = specularReflection;
			  o.tex = v.texcoord;

			  return o;
		  }

		  fixed4 frag(VertexOutput i) : COLOR {
			  return fixed4(i.specularColor + i.diffuseColor * tex2D(_MainTex, i.tex.xy), _Color.a);
		  }

		  ENDCG
	  }
		}
}
