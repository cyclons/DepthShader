///
/// Basic wireframe shader that can be used for rendering spatial mapping meshes.
///
Shader "Hololens Shader Pack/Wire floating"
{
	Properties
	{
		_WireColor("Wire color", Color) = (1.0, 1.0, 1.0, 1.0)
		[PowerSlider(2.0)]  _Amount("Wire Thickness", Range(0.0001,0.1)) = 0.01
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry+1" }

		Pass
		{
			Cull Front
			ColorMask 0

			CGPROGRAM
			#include "HoloCP.cginc"

			#pragma vertex vert
			#pragma fragment frag
		
			fixed _Amount;

			struct v2f
			{
				fixed4 viewPos : SV_POSITION;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2f vert(appdata_base v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				o.viewPos = UnityObjectToClipPos(v.vertex);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				return o;
			}

			fixed4 frag(v2f i) : COLOR
			{
				return 0;
			}
			ENDCG
		}

		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent-1" }
		

		Pass
		{
			Cull Front
	
			CGPROGRAM
			#include "HoloCP.cginc"

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _WireColor;
			fixed _Amount;

			struct v2f
			{
				fixed4 viewPos : SV_POSITION;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2f vert(appdata_base v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
	 			o.viewPos = UnityObjectToClipPos(v.vertex + normalize(v.normal) * _Amount);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				return o;
			}

			fixed4 frag(v2f i) : COLOR
			{
				return _WireColor;
			}
			ENDCG
		}		
	}
	FallBack "Diffuse"
}

