#!/usr/bin/env bash
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

copyright() {
    clear
    echo "\
############################################################
Linux网络优化脚本 (生产环境慎用)
############################################################
"
}

remove_tcp_parameters() {
    local parameters=(
        net.ipv4.tcp_no_metrics_save
        net.ipv4.tcp_ecn
        net.ipv4.tcp_frto
        net.ipv4.tcp_mtu_probing
        net.ipv4.tcp_rfc1337
        net.ipv4.tcp_sack
        net.ipv4.tcp_fack
        net.ipv4.tcp_window_scaling
        net.ipv4.tcp_adv_win_scale
        net.ipv4.tcp_moderate_rcvbuf
        net.core.rmem_max
        net.core.wmem_max
        net.ipv4.udp_rmem_min
        net.ipv4.udp_wmem_min
        net.core.default_qdisc
        net.ipv4.tcp_congestion_control
    )
    
    for param in "${parameters[@]}"; do
        sed -i "/$param/d" /etc/sysctl.conf
    done
}

tcp_tune() {
    remove_tcp_parameters
    
    cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_ecn=0
net.ipv4.tcp_frto=0
net.ipv4.tcp_mtu_probing=0
net.ipv4.tcp_rfc1337=0
net.ipv4.tcp_sack=1
net.ipv4.tcp_fack=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_adv_win_scale=1
net.ipv4.tcp_moderate_rcvbuf=1
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 16384 16777216
net.ipv4.udp_rmem_min=8192
net.ipv4.udp_wmem_min=8192
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF

    sysctl -p && sysctl --system
}

enable_forwarding() {
    sed -i '/net.ipv4.conf.all.route_localnet/d' /etc/sysctl.conf
    sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
    sed -i '/net.ipv4.conf.all.forwarding/d' /etc/sysctl.conf
    sed -i '/net.ipv4.conf.default.forwarding/d' /etc/sysctl.conf
    
    cat >> '/etc/sysctl.conf' << EOF
net.ipv4.conf.all.route_localnet=1
net.ipv4.ip_forward=1
net.ipv4.conf.all.forwarding=1
net.ipv4.conf.default.forwarding=1
EOF

    sysctl -p && sysctl --system
}

copyright
tcp_tune
enable_forwarding
echo -e "${Info}脚本执行完毕，已应用所有更改。"