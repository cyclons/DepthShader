Shader "Hololens Shader Pack/PatternAndHighlight"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Base Color", Color) = (0.0, 0.0, 0.0)
		_Scale("Scale", Range(0.1, 10)) = 1.0

		[Header(Highlight)]
		[Toggle] _LookAtEnabled("Enabled", Float) = 0
		_HighlightColor("Color", Color) = (1.0, 0.8, 0.01)
		_LookAtPoint("Center", Vector) = (0.0, 0.0, 0.0)
		_LookAtRadius("Radius", Range(0.0, 5)) = 0.5
		_LookAtCellScale("Blocks", Range(1, 10)) = 2

		[Header(Pulse Transition)]
		[Toggle] _PulseEnabled("Enabled", Float) = 0
		_Center("Center", Vector) = (0,0,0,0)
		_TransitionOffset("Pulse Offset", Range(-1, 10)) = 0.5
		_TransitionWidth("Pulse Width", Range(0, 5.0)) = 1.0
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

			uniform sampler2D	_MainTex;
			uniform half4		_MainTex_ST;

			fixed3 _Color;
			fixed _Scale;

			fixed _LookAtEnabled;
			fixed3 _HighlightColor;
			fixed3 _LookAtPoint;
			half _LookAtRadius;
			half _LookAtCellScale;

			fixed _PulseEnabled;
			fixed _TransitionOffset;
			fixed _TransitionWidth;
			fixed4 _Center;
			fixed _Power;

			fixed _FadeEnabled;
			fixed _FadeEnd;
			fixed _FadeRange;

			struct v2f
			{
				fixed4 vertex : SV_POSITION;
				fixed3 tpn : TEXCOORD0;
				fixed4 world : TEXCOORD1;
				fixed4 scaled : TEXCOORD2;
				fixed3 fade : TEXCOORD3;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2f vert(appdata_base v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.tpn = normalize(abs(mul(unity_ObjectToWorld, fixed4(v.normal, 0.0)).xyz));
				o.world = mul(unity_ObjectToWorld, v.vertex);
				o.scaled = o.world / _Scale;
				o.fade = ComputeNearPlaneTransition(v.vertex, _FadeEnd, _FadeRange);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 o;
				fixed2 c = i.scaled.xy;
				if (i.tpn.x > i.tpn.y && i.tpn.x > i.tpn.z)
				{
					c = i.scaled.zy;
				}
				else if (i.tpn.y > i.tpn.x && i.tpn.y > i.tpn.z)
				{
					c = i.scaled.xz;
				}

				o.rgb = tex2D(_MainTex, c).x * _Color;

				fixed4 transition = 1;
				if (_PulseEnabled > 0)
				{
					transition = pow(getPulse(i.world.xyz, _Center, _TransitionOffset, _TransitionWidth, 1.0), _Power);
				}
				o.rgb *= transition.x;
				if (_LookAtEnabled)
				{
					fixed _LookatSize = _Scale / _LookAtCellScale;
					half d = cubicPulse(0., _LookAtRadius, distance(_LookAtPoint, floor((i.world.xyz + 0.5 * _LookatSize) / _LookatSize) * _LookatSize));
					o.rgb += d * _HighlightColor;
				}
				if (_FadeEnabled)
				{
					o.rgb *= i.fade.x;
				}
				return fixed4(o.rgb, 1);
			}
			ENDCG
		}
	}
}
