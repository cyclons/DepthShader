Shader "Hololens Shader Pack/TriPlanar Single Texture" 
{
	Properties
	{
		_MainTex("Color (RGB)", 2D) = "white" {}
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

			uniform sampler2D	_MainTex;
			uniform half4		_MainTex_ST;

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

				fixed4 cx = tex2D(_MainTex, i.world.zy * _MainTex_ST.xy + _MainTex_ST.zw);
				fixed4 cy = tex2D(_MainTex, i.world.xz * _MainTex_ST.xy + _MainTex_ST.zw);
				fixed4 cz = tex2D(_MainTex, i.world.xy * _MainTex_ST.xy + _MainTex_ST.zw);

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
