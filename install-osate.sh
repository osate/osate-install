#!/bin/sh
################################################################################
# Copyright (c) 2004-2020 Carnegie Mellon University and others. (see
# Contributors file).
# All Rights Reserved.
#
# NO WARRANTY. ALL MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE
# MELLON UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED
# OR IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO,
# WARRANTY OF FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR
# RESULTS OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON
# UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO
# FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
#
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0 which is
# available at https://www.eclipse.org/legal/epl-2.0/
# SPDX-License-Identifier: EPL-2.0
#
# Created, in part, with funding and support from the United States
# Government. (see Acknowledgments file).
#
# This program includes and/or can make use of certain third party
# source code, object code, documentation and other files ("Third
# Party Software"). The Third Party Software that is used by this
# program is dependent upon your system configuration. By using this
# program, You agree to comply with any and all relevant Third Party
# Software terms and conditions contained in any such Third Party
# Software or separate license file distributed with such Third Party
# Software. The parties who own the Third Party Software ("Third
# Party Licensors") are intended third party benefici- aries to this
# license with respect to the terms applicable to their Third Party
# Software. Third Party Software li- censes only apply to the Third
# Party Software and not any other portion of this program or this
# program as a whole.

###############################################################################
# This script downloads and installs OSATE
#
###############################################################################

# URL to OSATE download repository
OSATE_DOWNLOAD_URL=https://osate-build.sei.cmu.edu/download/osate/stable/latest/products

###############################################################################
# Target specific configuration

case "$(uname -s)" in
    Darwin)
        OSATE_FILTER="macos"
        SED="gsed"
        ;;

    Linux)
        OSATE_FILTER="linux"
        SED="sed"
        ;;
esac

###############################################################################
# Download OSATE
#################

download_osate() {
    # 1. Extract the name of the binary from OSATE index.html page

    OSATE_BINARY=$(curl -s -L $OSATE_DOWNLOAD_URL | \
                       grep -io '<a href=['"'"'"][^"'"'"']*['"'"'"]' | \
                       $SED -e 's/^<a href=["'"'"']//i' -e 's/["'"'"']$//i' | grep $OSATE_FILTER)

    echo Installing "$OSATE_BINARY"

    OSATE_INSTALL_DIR=$(echo "$OSATE_BINARY" | cut -f1,2 -d'-')

    # 2. Download iff there is no local copy, or if the size does not
    #    match (e.g. case of an interrupted download).

    curl -C - $OSATE_DOWNLOAD_URL/"$OSATE_BINARY" --output "$OSATE_BINARY"

}

###############################################################################
# Install OSATE
###############

install_osate() {
    mkdir "$OSATE_INSTALL_DIR"

    case "$(uname -s)" in
        Darwin)
            tar -C "$OSATE_INSTALL_DIR" -xf "$OSATE_BINARY"
            echo Administrator password required to adjust quarantine status
            ( pushd $OSATE_INSTALL_DIR ; sudo xattr -rd com.apple.quarantine osate2.app/ ; popd)
            ;;

        Linux)
            tar -C "$OSATE_INSTALL_DIR" -xf "$OSATE_BINARY"
            ;;
    esac

    echo Latest OSATE release installed in "$OSATE_INSTALL_DIR"
}

###############################################################################
# Install plug-ins, see
# https://www.cs.ubc.ca/~gberseth/blog/install-eclipse-plugins-via-the-command-line.html
##################

install_plugins(){

    echo "Installing plug-ins"
    case "$(uname -s)" in
        Darwin)
            OSATE_BIN=$OSATE_INSTALL_DIR/osate2.app/Contents/MacOS/osate
            ;;

        Linux)
            ;;
    esac

    echo " installing Resolute"
    $OSATE_BIN -application org.eclipse.equinox.p2.director \
               -repository http://osate-build.sei.cmu.edu/download/osate/stable/2.3.7/updates \
               -installIU  com.rockwellcollins.atc.resolute.feature.feature.group -nosplash

    echo " installing Cheddar"
    $OSATE_BIN -application org.eclipse.equinox.p2.director \
               -repository https://osate-build.sei.cmu.edu/p2/ocarina \
               -installIU  org.osate.ocarina.feature.feature.group -nosplash

    echo " installing OpenModelica MDT"
    $OSATE_BIN -application org.eclipse.equinox.p2.director \
               -repository https://www.ida.liu.se/labs/pelab/modelica/OpenModelica/MDT/ \
               -installIU  org.modelica.mdt.feature.group -nosplash

#    echo " installing Papyrus/SysML"
#    $OSATE_BIN -Application org.eclipse.equinox.p2.director \
#               -repository https://download.eclipse.org/modeling/mdt/papyrus/updates/releases/2019-12/ \
#               -installIU org.eclipse.papyrus.uml.feature.feature.group,org.eclipse.papyrus.uml.feature.feature.group,org.eclipse.papyrus.uml.alf.feature.feature.group,org.eclipse.papyrus.uml.decoratormodel.feature.feature.group,org.eclipse.papyrus.uml.architecture.feature.feature.group,org.eclipse.papyrus.uml.diagram.feature.feature.group,org.eclipse.papyrus.uml.expressions.feature.feature.group,org.eclipse.papyrus.uml.internationalization.feature.feature.group,org.eclipse.papyrus.uml.m2m.qvto.feature.feature.group,org.eclipse.papyrus.uml.modelexplorer.feature.feature.group,org.eclipse.papyrus.uml.properties.feature.feature.group,org.eclipse.papyrus.uml.search.feature.feature.group,org.eclipse.papyrus.uml.nattable.feature.feature.group,org.eclipse.papyrus.uml.textedit.feature.feature.group,org.eclipse.papyrus.uml.tools.feature.feature.group,org.eclipse.papyrus.uml.ui.feature.feature.group,org.eclipse.papyrus.uml.diagram.css.feature.feature.group,org.eclipse.papyrus.infra.gmfdiag.css.feature.feature.group,org.eclipse.papyrus.uml.xtext.integration.feature.feature.group

#    $OSATE_BIN -application org.eclipse.equinox.p2.director \
#               -repository http://download.eclipse.org/modeling/mdt/papyrus/components/sysml14/ \
#               -installIU  org.eclipse.papyrus.sysml14.feature.feature.group -nosplash
}

###############################################################################
# Main processing starts here

download_osate
install_osate
#install_plugins
