// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/grass"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex("NoiseTex",2D) ="white"{}

		_WindSpeedX("_WindSpeedX",float) = 0.1
		_WindSpeedZ("_WindSpeedZ",float) = 0.1
	}
	SubShader
	{
		Cull OFF
		Tags { "RenderType"="Transparent" "Queue"="Transparent"}
		LOD 100

		Pass
		{
			
			ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
      
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
				
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			float _WindSpeedX;
			float _WindSpeedZ;

			v2f vert (appdata v)
			{

				//1、将模型坐标系下的坐标转动世界坐标


				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				float2 xz;
				xz.x = worldPos.x;
				xz.y = worldPos.z;

				float2 off_set  = _Time.y * float2(_WindSpeedX,_WindSpeedZ) * v.uv.y;


				 xz = xz + off_set;
				//worldPos.x = worldPos.x * (tex2Dlod(_NoiseTex,uv) - 0.5);
				float4 texColor = tex2Dlod(_NoiseTex, float4(xz, 0, 0)) - 0.5;
				//2、将世界坐标系下的坐标点转回模型坐标系
				worldPos.x = worldPos.x + texColor * 0.25;
				//worldPos.y = worldPos.y;
				//worldPos.z = worldPos.z;
				//worldPos.w = worldPos.w;

				//3、

				
		


				float4 modlePos = mul(unity_WorldToObject, worldPos);

				v2f o;
				o.vertex = UnityObjectToClipPos(modlePos);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				
				return col;
			}
			ENDCG
		}
	}
}
