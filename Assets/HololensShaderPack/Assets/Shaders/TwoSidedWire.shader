Shader "Hololens Shader Pack/Two Sided Wire"
{
	Properties
	{
		_WireColor("Wire color", Color) = (1.0, 1.0, 1.0, 1.0)
		_WireThickness("Wire thickness", Range(0, 800)) = 100
		_Back("Backside Darkness", Range(0,1)) = 0.5
	}
	
	SubShader
	{
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }

		Pass
		{
			Cull Front
			AlphaToMask On
			Blend SrcAlpha OneMinusSrcAlpha // Traditional transparency

			CGPROGRAM
			#include "HoloCP.cginc"

			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			fixed4 _WireColor;
			fixed _Back;
			fixed _WireThickness;

			struct v2g
			{
				fixed4 viewPos : SV_POSITION;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2g vert(appdata_base v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				v2g o;
				o.viewPos = UnityObjectToClipPos(v.vertex);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				return o;
			}

			struct g2f
			{
				fixed4 viewPos : SV_POSITION;
				fixed inverseW : TEXCOORD0;
				fixed3 dist : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			[maxvertexcount(3)]
			void geom(triangle v2g i[3], inout TriangleStream<g2f> triStream)
			{
				// Calculate the vectors that define the triangle from the input points.
				fixed2 point0 = i[0].viewPos.xy / i[0].viewPos.w;
				fixed2 point1 = i[1].viewPos.xy / i[1].viewPos.w;
				fixed2 point2 = i[2].viewPos.xy / i[2].viewPos.w;

				// Calculate the area of the triangle.
				fixed2 vector0 = point2 - point1;
				fixed2 vector1 = point2 - point0;
				fixed2 vector2 = point1 - point0;
				fixed area = abs(vector1.x * vector2.y - vector1.y * vector2.x);

				fixed3 distScale[3];
				distScale[0] = fixed3(area / length(vector0), 0, 0);
				distScale[1] = fixed3(0, area / length(vector1), 0);
				distScale[2] = fixed3(0, 0, area / length(vector2));

				fixed wireScale = 800 - _WireThickness;

				// Output each original vertex with its distance to the opposing line defined
				// by the other two vertices.
				g2f o;

				[unroll]
				for (uint idx = 0; idx < 3; ++idx)
				{
					o.viewPos = i[idx].viewPos;
					o.inverseW = 1.0 / o.viewPos.w;
					o.dist = distScale[idx] * o.viewPos.w * wireScale;
					UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(i[idx], o);
					triStream.Append(o);
				}
			}

			fixed4 frag(g2f i) : COLOR
			{
				// Calculate  minimum distance to one of the triangle lines, making sure to correct
				// for perspective-correct interpolation.
				fixed dist = min(i.dist[0], min(i.dist[1], i.dist[2])) * i.inverseW;

				// Make the intensity of the line very bright along the triangle edges but fall-off very
				// quickly.
				fixed I = exp2(-2 * dist * dist);

				// Fade out the alpha but not the color so we don't get any weird halo effects from
				// a fade to a different color.
				fixed4 color = _WireColor * _Back;
				color.a = I;
				return color;
			}
			ENDCG
		}

		Pass
		{
			Cull Back
			AlphaToMask On
			Blend SrcAlpha OneMinusSrcAlpha // Traditional transparency
			//Blend One OneMinusSrcAlpha // Premultiplied transparency

			CGPROGRAM
			#include "HoloCP.cginc"

			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			fixed4 _WireColor;
			fixed _WireThickness;

			struct v2g
			{
				fixed4 viewPos : SV_POSITION;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2g vert(appdata_base v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				v2g o;
				o.viewPos = UnityObjectToClipPos(v.vertex);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				return o;
			}

			struct g2f
			{
				fixed4 viewPos : SV_POSITION;
				fixed inverseW : TEXCOORD0;
				fixed3 dist : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			[maxvertexcount(3)]
			void geom(triangle v2g i[3], inout TriangleStream<g2f> triStream)
			{
				// Calculate the vectors that define the triangle from the input points.
				fixed2 point0 = i[0].viewPos.xy / i[0].viewPos.w;
				fixed2 point1 = i[1].viewPos.xy / i[1].viewPos.w;
				fixed2 point2 = i[2].viewPos.xy / i[2].viewPos.w;

				// Calculate the area of the triangle.
				fixed2 vector0 = point2 - point1;
				fixed2 vector1 = point2 - point0;
				fixed2 vector2 = point1 - point0;
				fixed area = abs(vector1.x * vector2.y - vector1.y * vector2.x);

				fixed3 distScale[3];
				distScale[0] = fixed3(area / length(vector0), 0, 0);
				distScale[1] = fixed3(0, area / length(vector1), 0);
				distScale[2] = fixed3(0, 0, area / length(vector2));

				fixed wireScale = 800 - _WireThickness;

				// Output each original vertex with its distance to the opposing line defined
				// by the other two vertices.
				g2f o;

				[unroll]
				for (uint idx = 0; idx < 3; ++idx)
				{
					o.viewPos = i[idx].viewPos;
					o.inverseW = 1.0 / o.viewPos.w;
					o.dist = distScale[idx] * o.viewPos.w * wireScale;
					UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(i[idx], o);
					triStream.Append(o);
				}
			}

			fixed4 frag(g2f i) : COLOR
			{
				// Calculate  minimum distance to one of the triangle lines, making sure to correct
				// for perspective-correct interpolation.
				fixed dist = min(i.dist[0], min(i.dist[1], i.dist[2])) * i.inverseW;

				// Make the intensity of the line very bright along the triangle edges but fall-off very
				// quickly.
				fixed I = exp2(-2 * dist * dist);

				// Fade out the alpha but not the color so we don't get any weird halo effects from
				// a fade to a different color.
				fixed4 color = _WireColor; // +(1 - I) * _BaseColor;
				color.a = I;
				return color;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}

