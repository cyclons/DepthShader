Shader "Custom/MeshScanShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_ScanTex("ScanTexure",2D) = "white"{}
		_ScanRange("ScanRange",float) = 0
		_ScanWidth("ScanWidth",float) = 0
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
				//return fixed4(linearDepth,linearDepth,linearDepth,linearDepth);

				float3 pixelWorldPos =_WorldSpaceCameraPos+linearDepth*i.interpolatedRay;
				float pixelDistance = distance(pixelWorldPos , _ScanCenter);

				//计算划分出的格子的坐标位置，归一化
				float3 modulo = pixelWorldPos - _MeshWidth*floor(pixelWorldPos/_MeshWidth);
				modulo = modulo/_MeshWidth;

				//在各个平面上计算对应的颜色吸收值
				fixed4 c_right = tex2D(_ScanTex,modulo.yz)*normal.x;
				fixed4 c_front = tex2D(_ScanTex,modulo.xy)*normal.z;
				fixed4 c_up = tex2D(_ScanTex,modulo.xz)*normal.y;
				//混合
				fixed4 scanMeshCol =saturate(c_up +c_right+c_front);

				////方案2
				//float2 calculatedUV = modulo.xy;
				//if (normal.x > normal.y && normal.x > normal.z)
				//{
				//	calculatedUV = modulo.yz;
				//}
				//else if (normal.y > normal.x && normal.y > normal.z)
				//{
				//	calculatedUV = modulo.xz;
				//}
				//fixed4 scanMeshCol = tex2D(_ScanTex,calculatedUV);

				//return scanMeshCol;
				
				//实现波纹扩散效果
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
