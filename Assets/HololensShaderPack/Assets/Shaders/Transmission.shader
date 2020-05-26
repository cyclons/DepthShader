Shader "Hololens Shader Pack/Transmission"
{
	Properties
	{
		_Color("Color", Color) = (0.26,0.19,0.16,0.0)
		_Offset("Offset", Range(0.0,1.0)) = 0.0
		_Scale("Scale", Range(0.0,10.0)) = 1.0
		_RimPower("Rim Power", Range(0.1,8.0)) = 3.0

		[Header(Transmission)]
		_TransmissionPlane("Plane", Vector) = (0.0, 1., 0.0, 0.0)
		_Range("Range",  Range(1.0,10.0)) = 1.0
		_Speed("Speed",  Range(-10., 10.)) = -5.0
	}

	SubShader 
	{
		Tags { "RenderType" = "Transparent"  "Queue" = "Transparent-1" }
		Blend OneMinusDstColor One

		Pass
		{
			Cull Off
			ZWrite Off
			Blend OneMinusDstColor One // Soft Additive

			Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent" }

			CGPROGRAM
			#include "HoloCP.cginc"

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;
			fixed _Offset;
			fixed _Scale;
			fixed _RimPower;
			fixed3 _TransmissionPlane;
			fixed _Range;
			fixed _Speed;

			struct v2f
			{
				fixed4 viewPos : SV_POSITION;
				fixed3 normal: NORMAL;
				fixed3 worldSpaceViewDir: TEXCOORD0;
				fixed4 world : TEXCOORD1;
				fixed2 offset: TEXCOORD2;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2f vert(appdata_base v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				o.viewPos = UnityObjectToClipPos(v.vertex);
				o.worldSpaceViewDir = WorldSpaceViewDir(v.vertex);
				o.normal = normalize(mul(unity_ObjectToWorld, fixed4(v.normal, 0.0)).xyz);
				o.world = mul(unity_ObjectToWorld, v.vertex);

				fixed3 transmissionDir = normalize(_TransmissionPlane.xyz);
				o.offset.x = dot(o.world, transmissionDir);
				o.offset.y = abs(dot(o.normal, transmissionDir));
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				return o;
			}

			fixed4 frag(v2f i) : COLOR
			{
				fixed4 o = 0;
				half rim = 1. - abs(dot(normalize(i.worldSpaceViewDir), i.normal));
				o.rgb = saturate(smoothstep(1., 0.75, i.offset.y) * (0.5 + 0.5 * sin(62.8 * i.offset.x * _Range + _Time.w * _Speed)) * _Color.rgb * (_Offset + _Scale * pow(rim, _RimPower)));
				return o;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
