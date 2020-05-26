/*
Shader that uses a 4 channel texture with two differently scaled patterns.
-Red channel,	Large Distance Field
-Green channel, Large Cell Id
-Blue channel,	Small Distance Field
-Alpha channel, Small Cell Id
*/
Shader "Hololens Shader Pack/CellsAndLines"
{
	Properties
	{
		_SDIDTexture("Texture", 2D) = "white" {}
		_Color("Base Color", Color) = (0.2, 0.5, 1.0)
		_Scale("Scale", Range(0.1, 10)) = 1
		[PowerSlider(2.0)]  _LargeThickness("Large Line Thickness", Range(0, 0.5)) = 0.1
		[PowerSlider(2.0)]  _SmallThickness("Small Line Thickness", Range(0, 0.5)) = 0.1
		_CellOffset("Cell Offset", Range(0, 1.0)) = 0.2
		_CellVariation("Cell Variation Scale", Range(0, 1.0)) = 0.2
		_CellSpeed("Cell Variation Speed", Range(0, 10)) = 5

		[Header(Pulse Transition)]
		[Toggle] _PulseEnabled("Enabled", Float) = 0
		_Center("Center", Vector) = (0,0,0,0)
		_TransitionOffset("Pulse Offset", Range(-1, 10)) = 0.5
		_TransitionWidth("Pulse Width", Range(0, 2.0)) = 1.0
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
			fixed _LargeThickness;
			fixed _SmallThickness;

			fixed _CellOffset;
			fixed _CellVariation;
			fixed _CellSpeed;

			fixed _PulseEnabled;
			fixed _TransitionOffset;
			fixed _TransitionWidth;
			fixed _DetailedTransitionWidth;
			fixed4 _Center;
			fixed _Power;

			fixed _FadeEnabled;
			fixed _FadeEnd;
			fixed _FadeRange;

			uniform sampler2D	_SDIDTexture;
			uniform fixed4		_SDIDTexture_ST;

			struct v2f
			{
				fixed4 vertex : SV_POSITION;
				fixed3 tpn : TEXCOORD0;
				fixed4 world : TEXCOORD1;
				fixed4 scaled : TEXCOORD2;
				fixed fade : TEXCOORD3;
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
				o.fade.x = ComputeNearPlaneTransition(v.vertex, _FadeEnd, _FadeRange);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 o = 0;
				fixed2 c = i.scaled.xy;
				if (i.tpn.x > i.tpn.y && i.tpn.x > i.tpn.z)
				{
					c = i.scaled.zy;
				}
				else if (i.tpn.y > i.tpn.x && i.tpn.y > i.tpn.z)
				{
					c = i.scaled.xz;
				}

				fixed4 tex = tex2D(_SDIDTexture, c);
				fixed4 transition = 1;
				if (_PulseEnabled > 0)
				{
					transition = pow(getPulse(i.world.xyz, _Center, _TransitionOffset, _TransitionWidth, _DetailedTransitionWidth), _Power);
				}
				fixed2 l = smoothstep(fixed2(_LargeThickness, _SmallThickness), 0.0, tex.xz) * transition.xy;
				fixed cell = transition.y * (_CellOffset + 0.5 * _CellVariation * sin(_Time.y * 0.333 * _CellSpeed + 6.28 * tex.g) + _CellVariation * sin(_Time.y * _CellSpeed + 6.28 * tex.a));
				o.rgb = max(cell, max(l.x, l.y)) * _Color * transition.z;
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
