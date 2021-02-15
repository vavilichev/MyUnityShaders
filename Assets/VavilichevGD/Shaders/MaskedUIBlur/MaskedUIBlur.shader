// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "UI/MaskedUIBlur" {
    Properties {
        _BlurSize ("Blur Size", Range(0, 30)) = 1
        [HideInInspector] _MainTex ("Tint Color (RGB)", 2D) = "white" {}
        [Space(15)]
        [MaterialToggle] _ColoringEnabled("Coloring Enabled", Float) = 0
        _Color ("Color", Color) = (1,1,1,1)
        _ColorAlphaTrashold ("Color Alpha Trashold", Range(0.0, 1.0)) = 0.5
    }
    Category {
    
        
        Tags { 
            "Queue"="Transparent" 
            "IgnoreProjector"="True" 
            "RenderType"="Opaque" 
        }
        
        SubShader
        {
            // Horizontal blur
            GrabPass
            {
                "_HBlur"
            }
 
            Pass
            {            
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma fragmentoption ARB_precision_hint_fastest
                #include "UnityCG.cginc"
           
                struct appdata_t {
                    float4 vertex : POSITION;
                    float2 texcoord: TEXCOORD0;
                };
           
                struct v2f {
                    float4 vertex : POSITION;
                    float4 uvgrab : TEXCOORD0;
                    float2 uvmain : TEXCOORD1;
                };
 
                sampler2D _MainTex;
                float4 _MainTex_ST;
                float _ColoringEnabled;
                fixed4 _Color;
                float _ColorAlphaTrashold;

 
                v2f vert (appdata_t v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
 
                    #if UNITY_UV_STARTS_AT_TOP
                    float scale = -1.0;
                    #else
                    float scale = 1.0;
                    #endif
 
                    o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y * scale) + o.vertex.w) * 0.5;
                    o.uvgrab.zw = o.vertex.zw;
 
                    o.uvmain = TRANSFORM_TEX(v.texcoord, _MainTex);
                    return o;
                }
           
                sampler2D _HBlur;
                float4 _HBlur_TexelSize;
                float _BlurSize;
 
                half4 frag( v2f i ) : COLOR
                {    
                    float alpha = tex2D(_MainTex, i.uvmain).a;
                    half4 sum = half4(0,0,0,0);
 
                    #define GRABPIXEL(weight,kernelx) tex2Dproj( _HBlur, UNITY_PROJ_COORD(float4(i.uvgrab.x + _HBlur_TexelSize.x * kernelx * _BlurSize * alpha, i.uvgrab.y, i.uvgrab.z, i.uvgrab.w))) * weight
 
                    sum += GRABPIXEL(0.05, -4.0);
                    sum += GRABPIXEL(0.09, -3.0);
                    sum += GRABPIXEL(0.12, -2.0);
                    sum += GRABPIXEL(0.15, -1.0);
                    sum += GRABPIXEL(0.18,  0.0);
                    sum += GRABPIXEL(0.15, +1.0);
                    sum += GRABPIXEL(0.12, +2.0);
                    sum += GRABPIXEL(0.09, +3.0);
                    sum += GRABPIXEL(0.05, +4.0);
  
                    if (_ColoringEnabled > 0 && alpha > _ColorAlphaTrashold)
                        sum *= _Color;
 
                    return sum;
                }
                ENDCG
            }
 
            // Vertical blur
            GrabPass
            {
                "_VBlur"
            }
 
            Pass
            {            
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma fragmentoption ARB_precision_hint_fastest
                #include "UnityCG.cginc"
           
                struct appdata_t {
                    float4 vertex : POSITION;
                    float2 texcoord: TEXCOORD0;
                };
           
                struct v2f {
                    float4 vertex : POSITION;
                    float4 uvgrab : TEXCOORD0;
                    float2 uvmain : TEXCOORD1;
                };
 
                sampler2D _MainTex;
                float4 _MainTex_ST;
 
                v2f vert (appdata_t v) {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
 
                    #if UNITY_UV_STARTS_AT_TOP
                    float scale = -1.0;
                    #else
                    float scale = 1.0;
                    #endif
 
                    o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y * scale) + o.vertex.w) * 0.5;
                    o.uvgrab.zw = o.vertex.zw;
 
                    o.uvmain = TRANSFORM_TEX(v.texcoord, _MainTex);
 
                    return o;
                }
           
                sampler2D _VBlur;
                fixed4 _Color;
                float4 _VBlur_TexelSize;
                float _ColoringEnabled;
                float _BlurSize;
                float _ColorAlphaTrashold;

           
                half4 frag( v2f i ) : COLOR
                {
                    float alpha = tex2D(_MainTex, i.uvmain).a;
                    half4 sum = half4(0,0,0,0);
 
                    #define GRABPIXEL(weight,kernely) tex2Dproj( _VBlur, UNITY_PROJ_COORD(float4(i.uvgrab.x, i.uvgrab.y + _VBlur_TexelSize.y * kernely * _BlurSize * alpha, i.uvgrab.z, i.uvgrab.w))) * weight
 
                    sum += GRABPIXEL(0.05, -4.0);
                    sum += GRABPIXEL(0.09, -3.0);
                    sum += GRABPIXEL(0.12, -2.0);
                    sum += GRABPIXEL(0.15, -1.0);
                    sum += GRABPIXEL(0.18,  0.0);
                    sum += GRABPIXEL(0.15, +1.0);
                    sum += GRABPIXEL(0.12, +2.0);
                    sum += GRABPIXEL(0.09, +3.0);
                    sum += GRABPIXEL(0.05, +4.0);
                    
                    if (_ColoringEnabled > 0 && alpha > _ColorAlphaTrashold)
                        sum *= _Color;
 
                    return sum;
                }
                ENDCG
            }
        }
    }
}