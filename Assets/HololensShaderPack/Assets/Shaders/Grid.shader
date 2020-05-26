Shader "Hololens Shader Pack/Grid"
{
	Properties
	{
		_Color("Base Color", Color) = (0.0, 0.0, 0.0)
		_Scale("Scale", Range(0.01, 2)) = .2
		_LineSize("Line Width Factor", Range(0.01, 0.5)) = .02
		_LineCrispness("Line Crispness Factor", Range(0, 1)) = .5
		_Smoothness("Seam Blending", Range(0, .5)) = .25
		_LineColorLarge("Line Color", Color) = (1.0, 0.8, 0.01)

		[Header(Pulse Transition)]
		[Toggle] _PulseEnabled("Enabled", Float) = 0
		_Center("Center", Vector) = (0,0,0,0)
		_TransitionOffset("Pulse Offset", Range(-1, 10)) = 0.5
		_TransitionWidth("Pulse Width", Range(0, 5.0)) = 1.0
		_DetailedTransitionWidth("Detail Width Factor", Range(0, 1)) = 0.5
		_Power("Smoothness", Range(0, 5.0)) = 1.0

		[Header(Near Fade)]
		[Toggle] _FadeEnabled("Enabled", Float) = 0
		_FadeEnd("Fade End (Near Plane)", Range(0, 1)) = 0.85
		_FadeRange("Fade Range", Range(0, 2.0)) = 0.5
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

			fixed3 _Color;
			fixed _Scale;
			fixed _LineSize;
			fixed _LineCrispness;
			fixed _Smoothness;
			fixed3 _LineColorLarge;

			fixed _PulseEnabled;
			fixed _TransitionOffset;
			fixed _TransitionWidth;
			fixed _DetailedTransitionWidth;
			fixed4 _Center;
			fixed _Power;

			fixed _FadeEnabled;
			fixed _FadeEnd;
			fixed _FadeRange;

			struct v2f
			{
				fixed4 vertex : SV_POSITION;
				fixed4 world : TEXCOORD0;
				fixed3 scaled : TEXCOORD1;
				fixed3 fade: TEXCOORD2;
				fixed3 tpn : TEXCOORD3;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2f vert(appdata_base v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o ;
				o.vertex = UnityObjectToClipPos(v.vertex);
				fixed3 normal = normalize(mul(unity_ObjectToWorld, fixed4(v.normal, 0.0)).xyz);
				o.tpn = max(0, (abs(normal) - _Smoothness));
				o.tpn /= dot(o.tpn, 1);
				o.world = mul(unity_ObjectToWorld, v.vertex);
				o.scaled = o.world / _Scale;
				o.fade = ComputeNearPlaneTransition(v.vertex, _FadeEnd, _FadeRange);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				return o;
			}

			fixed3 doGrid(fixed ls, fixed lcr, fixed3 lc, fixed3 pos, fixed3 tpn)
			{
				fixed3 modulo = mod(pos, 1);
				fixed3 t = smoothstep(ls, max(ls - lcr, 0.), modulo) + smoothstep(1 - ls, min(1 - ls + lcr, 1), modulo);
				return lerp(_Color, lc, saturate(dot(t, 1 - tpn)));
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 o = 0;
				fixed4 transition = 1;
				if (_PulseEnabled > 0)
				{
					transition = pow(getPulse(i.world.xyz, _Center, _TransitionOffset, _TransitionWidth, _DetailedTransitionWidth), _Power);
				}
				o.rgb = transition.x * doGrid(_LineSize, _LineSize * max(0.01, (1 -_LineCrispness)), transition.y * _LineColorLarge, i.scaled.xyz, i.tpn);
				if (_FadeEnabled)
				{
					o.rgb *= i.fade.x;
				}
				return o;
			}
			ENDCG
		}
	}
}
