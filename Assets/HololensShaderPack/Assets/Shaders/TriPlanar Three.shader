Shader "Hololens Shader Pack/TriPlanar Three Textures"
{
	Properties
	{
		_MainTexX("Color X (RGB)", 2D) = "red" {}
		_MainTexY("Color Y (RGB)", 2D) = "white" {}
		_MainTexZ("Color Z (RGB)", 2D) = "Blue" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#include "HoloCP.cginc"

			#pragma vertex vert
			#pragma fragment frag

			uniform sampler2D	_MainTexX;
			uniform half4		_MainTexX_ST;
			uniform sampler2D	_MainTexY;
			uniform half4		_MainTexY_ST;
			uniform sampler2D	_MainTexZ;
			uniform half4		_MainTexZ_ST;

			struct v2f
			{
				fixed4 vertex : SV_POSITION;
				fixed3 normal: NORMAL;
				fixed4 world : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2f vert(appdata_base v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = mul(unity_ObjectToWorld, fixed4(v.normal, 0.0)).xyz;
				o.world = mul(unity_ObjectToWorld, v.vertex);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				return o;
			}

			half4 frag(v2f i) : COLOR
			{
				half3 blend = abs(i.normal);
				blend /= dot(blend,1.0);

				fixed4 cx = tex2D(_MainTexX, i.world.zy * _MainTexX_ST.xy + _MainTexX_ST.zw);
				fixed4 cy = tex2D(_MainTexY, i.world.xz * _MainTexY_ST.xy + _MainTexY_ST.zw);
				fixed4 cz = tex2D(_MainTexZ, i.world.xy * _MainTexZ_ST.xy + _MainTexZ_ST.zw);

				// blend the textures based on weights
				fixed4 c = cx * blend.x + cy * blend.y + cz * blend.z;
				return c;

				// Debug output
				//return  half4(blend, 1);
				//return half4 (0.5 + 0.5 * normalize(i.normal), 1);
			}
			ENDCG
		}
	}
}
