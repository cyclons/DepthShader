Shader "Hololens Shader Pack/Gradient"
{
	Properties
	{
		_InnerColor("Inner Color", Color) = (0.26,0.19,0.16,0.0)
		_OuterColor("Outer Color", Color) = (0.26,0.19,0.16,0.0)
		_Offset("Offset", Range(0.0,1.0)) = 0.0
		_Scale("Scale", Range(0.0,10.0)) = 1.0
		_RimPower("Rim Power", Range(0.1,8.0)) = 3.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			Cull Back

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			fixed4 _InnerColor;
			fixed4 _OuterColor;
			fixed _Offset;
			fixed _Scale;
			fixed _RimPower;

			struct v2f
			{
				fixed4 viewPos : SV_POSITION;
				fixed3 normal : NORMAL;
				fixed3 worldSpaceViewDir : TEXCOORD0;
				fixed4 world : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};
			
			v2f vert(appdata_base v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				o.viewPos = UnityObjectToClipPos(v.vertex);
				o.worldSpaceViewDir = WorldSpaceViewDir(v.vertex);
				o.normal = mul(unity_ObjectToWorld, fixed4(v.normal, 0.0)).xyz;
				o.world = mul(unity_ObjectToWorld, v.vertex);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = 1;
				fixed rim = 1.0 - saturate(dot(normalize(i.worldSpaceViewDir), normalize(i.normal)));
				col.xyz = saturate(lerp(_InnerColor.rgb, _OuterColor.rgb, (_Offset + _Scale * pow(rim, _RimPower))));
				return col;
			}
			ENDCG
		}
	}
}
