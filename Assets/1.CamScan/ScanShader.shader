Shader "Custom/ScanShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_ScanDepth("ScanDepth",float)=0
		_ScanWidth("ScanWidth",float)=1
		_CamFar("CamFar",float)=500
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
				float2 uv_depth:TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
				o.uv_depth = v.uv.xy;
                return o;
            }

            sampler2D _MainTex;
			float _ScanDepth;
			float _ScanWidth;
			float _CamFar;

			sampler2D_float _CameraDepthTexture;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
				
				//计算深度
				float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
				float linearDepth = Linear01Depth(depth);

				if(linearDepth<_ScanDepth&&linearDepth>_ScanDepth-_ScanWidth/_CamFar&&linearDepth<1)
				{
					//做一个渐变效果
					fixed scanPercent = 1 - (_ScanDepth-linearDepth)/(_ScanWidth/_CamFar);
					return lerp(col,fixed4(1,1,0,1),scanPercent);
				}

                return col;
            }
            ENDCG
        }
    }
}
