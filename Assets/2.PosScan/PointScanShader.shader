Shader "Custom/PointScanShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_ScanTex("ScanTexure",2D) = "white"{}
		_ScanRange("ScanRange",float) = 0
		_ScanWidth("ScanWidth",float) = 0
		_ScanBgColor("ScanBgColor",color)=(1,1,1,1)
		_ScanMeshColor("ScanMeshColor",color)=(1,1,1,1)
		_MeshLineWidth("MeshLineWidth",float)=0.3
		_MeshWidth("MeshWidth",float)=1
		_Smoothness("SeamBlending",Range(0,0.5))=0.25
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
                float2 uv_depth : TEXCOORD1;
                float4 interpolatedRay : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

			
			float4x4 _FrustumCorner;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
				o.uv_depth = v.uv;

				int rayIndex;
				if(v.uv.x<0.5&&v.uv.y<0.5){
					rayIndex = 0;
				}else if(v.uv.x>0.5&&v.uv.y<0.5){
					rayIndex = 1;
				}else if(v.uv.x>0.5&&v.uv.y>0.5){
					rayIndex = 2;
				}else{
					rayIndex = 3;
				}
				o.interpolatedRay = _FrustumCorner[rayIndex];

                return o;
            }

            sampler2D _MainTex;
            sampler2D _ScanTex;
			float _ScanRange;
			float _ScanWidth;
			float3 _ScanCenter;
			fixed4 _ScanBgColor;
			fixed4 _ScanMeshColor;
			float _MeshLineWidth;
			float _MeshWidth;
			float4x4 _CamToWorld;
			fixed _Smoothness;
			
			sampler2D_float _CameraDepthTexture;
			sampler2D _CameraDepthNormalsTexture;

            fixed4 frag (v2f i) : SV_Target
            {
				float tempDepth;
				half3 normal;  
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), tempDepth, normal);  
				normal = mul( (float3x3)_CamToWorld, normal);  
				normal = normalize(max(0, (abs(normal) - _Smoothness)));
				//return fixed4(abs( normal),1);

                fixed4 col = tex2D(_MainTex, i.uv);
				float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
				float linearDepth = Linear01Depth(depth);

				float3 pixelWorldPos =_WorldSpaceCameraPos+linearDepth*i.interpolatedRay;

				float pixelDistance = distance(pixelWorldPos , _ScanCenter);

				float3 pixelDir = pixelWorldPos - _ScanCenter;

				float3 modulo = pixelWorldPos - _MeshWidth*floor(pixelWorldPos/_MeshWidth);
				modulo = modulo/_MeshWidth;

				float3 meshCol = smoothstep(_MeshLineWidth,0,modulo)+smoothstep(1-_MeshLineWidth,1,modulo);
				fixed4 scanMeshCol = lerp(_ScanBgColor,_ScanMeshColor,saturate(dot(meshCol,1-normal)));
				

				if(_ScanRange - pixelDistance > 0 && _ScanRange - pixelDistance <_ScanWidth &&linearDepth<1){
					fixed scanPercent = 1 - (_ScanRange - pixelDistance)/_ScanWidth;
					col = lerp(col,scanMeshCol,scanPercent);
				}

                return col;
            }
            ENDCG
        }
    }
}
