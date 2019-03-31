//
//	Code repository for GPU noise development blog
//	http://briansharpe.wordpress.com
//	https://github.com/BrianSharpe
//
//	I'm not one for copyrights.  Use the code however you wish.
//	All I ask is that credit be given back to the blog or myself when appropriate.
//	And also to let me know if you come up with any changes, improvements, thoughts or interesting uses for this stuff. :)
//	Thanks!
//
//	Brian Sharpe
//	brisharpe CIRCLE_A yahoo DOT com
//	http://briansharpe.wordpress.com
//	https://github.com/BrianSharpe
//
//===============================================================================
//  Scape Software License
//===============================================================================
//
//Copyright (c) 2007-2012, Giliam de Carpentier
//All rights reserved.
//
//Redistribution and use in source and binary forms, with or without
//modification, are permitted provided that the following conditions are met: 
//
//1. Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer. 
//2. Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution. 
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNERS OR CONTRIBUTORS BE LIABLE 
//FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
//DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
//SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
//CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
//OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
//OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.;

Shader "Noise/MyShader" 
{
	Properties 
	{
		_Octaves ("Octaves", Float) = 8.0
		_Frequency ("Frequency", Float) = 1.0
		_Amplitude ("Amplitude", Float) = 1.0
		_Lacunarity ("Lacunarity", Float) = 1.92
		_Persistence ("Persistence", Float) = 0.8
		_Offset ("Offset", Vector) = (0.0, 0.0, 0.0, 0.0)

	}

	CGINCLUDE
		//
		//	FAST32_hash
		//	A very fast hashing function.  Requires 32bit support.
		//	http://briansharpe.wordpress.com/2011/11/15/a-fast-and-simple-32bit-floating-point-hash-function/
		//
		//	The hash formula takes the form....
		//	hash = mod( coord.x * coord.x * coord.y * coord.y, SOMELARGEFLOAT ) / SOMELARGEFLOAT
		//	We truncate and offset the domain to the most interesting part of the noise.
		//	SOMELARGEFLOAT should be in the range of 400.0->1000.0 and needs to be hand picked.  Only some give good results.
		//	3D Noise is achieved by offsetting the SOMELARGEFLOAT value by the Z coordinate
		//
		void FAST32_hash_2D( float2 gridcell, out float4 hash_0, out float4 hash_1 )	//	generates 2 random numbers for each of the 4 cell corners
		{
			//    gridcell is assumed to be an integer coordinate
			const float2 OFFSET = float2( 26.0, 161.0 );
			const float DOMAIN = 71.0;
			const float2 SOMELARGEFLOATS = float2( 951.135664, 642.949883 );
			float4 P = float4( gridcell.xy, gridcell.xy + 1.0 );
			P = P - floor(P * ( 1.0 / DOMAIN )) * DOMAIN;
			P += OFFSET.xyxy;
			P *= P;
			P = P.xzxz * P.yyww;
			hash_0 = frac( P * ( 1.0 / SOMELARGEFLOATS.x ) );
			hash_1 = frac( P * ( 1.0 / SOMELARGEFLOATS.y ) );
		}
		//
		//	PerlinSurflet2D_Deriv
		//	Perlin Surflet 2D noise with derivatives
		//	returns float3( value, xderiv, yderiv )
		//
		float3 PerlinSurflet2D_Deriv( float2 P )
		{
			//	establish our grid cell and unit position
			float2 Pi = floor(P);
			float4 Pf_Pfmin1 = P.xyxy - float4( Pi, Pi + 1.0 );
		
			//	calculate the hash.
			float4 hash_x, hash_y;
			FAST32_hash_2D( Pi, hash_x, hash_y );
		
			//	calculate the gradient results
			float4 grad_x = hash_x - 0.49999;
			float4 grad_y = hash_y - 0.49999;
			float4 norm = rsqrt( grad_x * grad_x + grad_y * grad_y );
			grad_x *= norm;
			grad_y *= norm;
			float4 grad_results = grad_x * Pf_Pfmin1.xzxz + grad_y * Pf_Pfmin1.yyww;
		
			//	eval the surflet
			float4 m = Pf_Pfmin1 * Pf_Pfmin1;
			m = m.xzxz + m.yyww;
			m = max(1.0 - m, 0.0);
			float4 m2 = m*m;
			float4 m3 = m*m2;
		
			//	calc the deriv
			float4 temp = -6.0 * m2 * grad_results;
			float xderiv = dot( temp, Pf_Pfmin1.xzxz ) + dot( m3, grad_x );
			float yderiv = dot( temp, Pf_Pfmin1.yyww ) + dot( m3, grad_y );
		
			//	sum the surflets and return all results combined in a float3
			const float FINAL_NORMALIZATION = 2.3703703703703703703703703703704;		//	scales the final result to a strict 1.0->-1.0 range
			return float3( dot( m3, grad_results ), xderiv, yderiv ) * FINAL_NORMALIZATION;
		}
		float PerlinDerivedIQ(float2 p, int octaves, float2 offset, float frequency, float amplitude, float lacunarity, float persistence)
		{
		   float sum = 0;
		   float2 dsum = float2(0.0, 0.0);
		   for (int i = 0; i < octaves; i++)
		   {
			    float3 n = PerlinSurflet2D_Deriv((p + offset) * frequency);
			    dsum += n.yz;
			    sum += amplitude * n.x / (1 + dot(dsum, dsum));
			    frequency *= lacunarity;
			    amplitude *= persistence;
		   }
		   return sum;
		}

	ENDCG

	SubShader 
	{



		
		CGPROGRAM
		#pragma surface surf Lambert vertex:vert
		#pragma glsl
		#pragma target 3.0
		
		fixed _Octaves;
		float _Frequency;
		float _Amplitude;
		float2 _Offset;
		float _Lacunarity;
		float _Persistence;


		struct Input 
		{
			float2 pos;

		};

		void vert (inout appdata_full v, out Input OUT)
		{
			UNITY_INITIALIZE_OUTPUT(Input, OUT);
			OUT.pos = v.texcoord;
		}

		void surf (Input IN, inout SurfaceOutput o) 
		{
			float h = PerlinDerivedIQ(IN.pos.xy, _Octaves, _Offset, _Frequency, _Amplitude, _Lacunarity, _Persistence);
			

			
			float4 color = float4(h, h, h, h);

			o.Albedo = color.rgb;
			o.Alpha = 1.0;
		}
		ENDCG
	}
	
	FallBack "Diffuse"
}