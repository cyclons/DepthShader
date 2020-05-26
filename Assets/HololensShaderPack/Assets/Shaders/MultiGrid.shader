Shader "Hololens Shader Pack/MultiGrid" 
{
	Properties
	{
		_Color("Base Color", Color) = (0.0, 0.0, 0.0)
		_Scale("Scale", Range(0.1, 5)) = .5
		_LineSize("Line Width Factor", Range(0.01, 0.1)) = .02
		_LineCrispness("Line Crispness Factor", Range(0, 1)) = .5
		_Smoothness("Seam Blending", Range(0, .5)) = .25
		_LineColorLarge("Large Line Color", Color) = (1.0, 0.8, 0.01)
		_LineColorSmall("Small Line Color", Color) = (0.5, 0.8, 1.0)

		[Header(Pulse Transition)]
		[Toggle] _PulseEnabled("Enabled", Float) = 0
		_Center("Center", Vector) = (0,0,0,0)
		_TransitionOffset("Pulse Offset", Range(-1, 10)) = 0.5
		_TransitionWidth("Pulse Width", Range(0, 5.0)) = 1.0
		_DetailedTransitionWidth("Detail Width Factor", Range(0, 1)) = 0.5
		_Power("Smoothness", Range(0, 2.0)) = 1.0

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
			fixed3 _LineColorSmall;

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
				fixed2 fade : TEXCOORD2;
				fixed3 tpn : TEXCOORD3;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2f vert(appdata_base v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				fixed3 normal = normalize(mul(unity_ObjectToWorld, fixed4(v.normal, 0.0)).xyz);
				o.world = mul(unity_ObjectToWorld, v.vertex);
				o.tpn = max(0, (abs(normal.xyz) - _Smoothness));
				o.tpn /= dot(o.tpn, 1);
				o.scaled = o.world / _Scale;
				o.fade.x = ComputeNearPlaneTransition(v.vertex, _FadeEnd, _FadeRange);
				o.fade.y = _LineSize * max(0.01, (1 - _LineCrispness));
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 o = 0;
				fixed4 transition = 1;
				if (_PulseEnabled > 0)
				{
					transition = pow(getPulse(i.world.xyz, _Center, _TransitionOffset, _TransitionWidth, _DetailedTransitionWidth), _Power);
				}

				fixed3 modulo = mod(i.scaled.xyz, 1);
				fixed3 t = smoothstep(_LineSize, max(_LineSize - i.fade.y, 0), modulo) + smoothstep(1 - _LineSize, min(1 - _LineSize + i.fade.y, 1), modulo);
				o.rgb = transition.x * lerp(0.5 * _Color, _LineColorLarge, saturate(dot(t, 1 - i.tpn)));

				modulo = mod(i.scaled.xyz, 0.1);
				fixed ls = 0.5 * _LineSize;
				t = smoothstep(ls, max(ls - i.fade.y, 0), modulo) + smoothstep(0.1 - ls, min(0.1 - ls + i.fade.y, 0.1), modulo);
				o.rgb += transition.y * lerp(0.5 * _Color, _LineColorSmall, saturate(dot(t, 1 - i.tpn)));

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
