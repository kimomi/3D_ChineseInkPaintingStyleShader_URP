Shader "WJDR/HouseRoofTile"
{
	Properties {
		_Color ("Color", Color) = (0.5,0.5,0.5,0.5)
		_TexTop ("Top (RGB)", 2D) = "white" {}
		_TexSide ("Side (RGB)", 2D) = "white" {}
		_DetailTop ("Detail Top (RGB)", 2D) = "white" {}
		_DetailSide ("Detail Side (RGB)", 2D) = "white" {}
		
		_ScaleTex ("Scale Tex (top x, top y, side x , side y)", Vector) = (1,1,1,1)
		_ScaleTDetail ("Scale Detail (top x, top y, side x , side y)", Vector) = (1,1,1,1)
		
	}
	
	SubShader
	{
		Pass
		{
			Tags { "RenderType"="Opaque" }
			LOD 200

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0

			#include "UnityCG.cginc"

			sampler2D _TexTop;
			sampler2D _TexSide;
			sampler2D _DetailTop;
			sampler2D _DetailSide;
			
			float4 _ScaleTex;
			float4 _ScaleTDetail;
			fixed4 _Color;
			
			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
	    
			struct v2f
			{
				float4 worldPos : SV_POSITION;
				float3 worldNor : TEXCOORD0;
				float3 pointNor : TEXCOORD1;
				UNITY_FOG_COORDS(1)
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pointNor = abs(v.normal);
				o.worldNor = UnityObjectToWorldNormal(v.normal);
				o.worldPos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag (v2f IN) : SV_Target
			{
				float2 nzy = IN.worldPos.zy + float2(IN.worldPos.x, 0);
				float2 nzx = IN.worldPos.zx + float2(IN.worldPos.y, 0);
				float2 nxy = IN.worldPos.xy + float2(IN.worldPos.z, 0);
			
				float2 dir = normalize(IN.worldNor.zx);
				float2 dtuv = mul(float2x2(dir.y, -dir.x, dir.x, dir.y), IN.worldPos.zx) * _ScaleTDetail.xy;
			
				float3 tx = tex2D(_TexSide, nzy * _ScaleTex.zw) * tex2D(_DetailSide, nzy * _ScaleTDetail.zw);
				float3 ty = tex2D(_TexTop, nzx * _ScaleTex.xy) * tex2D(_DetailTop, dtuv);
				float3 tz = tex2D(_TexSide, nxy * _ScaleTex.zw) * tex2D(_DetailSide, nxy * _ScaleTDetail.zw);
				
				float3 rt = tx * IN.pointNor.x + ty * IN.pointNor.y + tz * IN.pointNor.z;

				// o.Albedo.rg = abs(normalize(IN.worldNor.zx));
				// o.Albedo.b = 0;
				return fixed4(rt * _Color.rgb * 2, _Color.a);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}